import SwiftUI

// MARK: - Main Search View

struct MyPlanFoodItemSearchView: View {

    @State var mealType: MealType

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    loadingView
                } else if foodItems.isEmpty && !searchText.isEmpty {
                    emptyStateView
                } else if foodItems.isEmpty {
                    placeholderView
                } else {
                    foodList
                }
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search foods…")
            .onChange(of: searchText) { _, newValue in
                debounceSearch(query: newValue)
            }
            .sheet(item: $detailFoodItem) { food in
                NavigationStack {
                    NutritionDetailSheet(food: food)
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Add") {
                                    addFood(food)
                                    dismiss()
                                }
                            }
                        }
                }
            }
            .alert("Something went wrong", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage ?? "An unexpected error occurred.")
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                        task?.cancel()
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    private var loadingView: some View {
        VStack(spacing: 10) {
            Spacer()
            ProgressView()
            Text("Searching…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("No results for \"\(searchText)\"")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var placeholderView: some View {
        VStack(spacing: 8) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(.tertiary)
            Text("Search to find food")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var foodList: some View {
        List(Array(foodItems).sorted(by: { $0.name < $1.name })) { food in
            FoodRowView(food: food)
                .onTapGesture {
                    detailFoodItem = food
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button {
                        addFood(food)
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                    .tint(.green)
                }
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
    }

    // MARK: - Private

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var foodItems: Set<FoodItemModel> = []
    @State private var task: URLSessionDataTask?
    @State private var detailFoodItem: FoodItemModel?
    @State private var showErrorAlert = false
    @State private var alertMessage: String?

    var isLoading: Bool { task?.state == .running }

    private func addFood(_ food: FoodItemModel) {
        Task {
            do {
                try await contentServiceHandler.addFoodToMyPlan(foodId: food.id, mealType: mealType)
                await MainActor.run { dismiss() }
            } catch {
                alertMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }

    private func debounceSearch(query: String) {
        guard !query.isEmpty else { foodItems = []; return }
        task?.cancel()
        foodItems.removeAll()
        task = NetworkManager.shared.fetchStreamedData(
            .GET,
            url: Endpoint.searchFoodItem.urlString,
            queryParameters: ["food_name": query, "limit": 10],
            headers: nil
        ) { (food: FoodItemModel) in
            DispatchQueue.main.async { foodItems.insert(food) }
        }
    }
}

// MARK: - Food Row

struct FoodRowView: View {
    let food: FoodItemModel

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: food.imageUri ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Color(.secondarySystemFill)
                        .overlay(
                            Image(systemName: "fork.knife")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        )
                }
            }
            .frame(width: 52, height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(food.name.capitalized)
                    .font(.system(.callout, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text("\(Int(food.totalCalories)) kcal  ·  \(food.type.displayLabel)  ·  \(food.state.rawValue.capitalized)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Nutrition Detail Sheet

struct NutritionDetailSheet: View {
    let food: FoodItemModel

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            HStack(spacing: 14) {
                AsyncImage(url: URL(string: food.imageUri ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Color(.secondarySystemFill)
                    }
                }
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name.capitalized)
                        .font(.headline)
                    Text(food.type.displayLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 20)

            Divider()
                .padding(.horizontal, 20)

            // Nutrition grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 1) {
                NutritionCell(label: "Calories", value: "\(Int(food.totalCalories))", unit: "kcal")
                NutritionCell(label: "Protein",  value: format(food.totalProteinInGrams), unit: "g")
                NutritionCell(label: "Carbs",    value: format(food.totalCarbsInGrams),   unit: "g")
                NutritionCell(label: "Fats",     value: format(food.totalFatsInGrams),    unit: "g")
                NutritionCell(label: "Sugar",    value: format(food.totalSugarInGrams),   unit: "g")
                NutritionCell(label: "Sodium",   value: format(food.totalSodiumInMiligrams), unit: "mg")
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            if !food.allergicIngredients.isEmpty {
                Divider()
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Allergens")
                        .font(.subheadline.weight(.medium))

                    Text(food.allergicIngredients.map { $0.rawValue.capitalized }.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }

            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel) {
                    dismiss()
                }
            }
        }
    }

    private func format(_ value: Double) -> String {
        unsafe String(format: "%.1f", value)
    }
}

// MARK: - Nutrition Cell

struct NutritionCell: View {
    let label: String
    let value: String
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 14)
    }
}

// MARK: - FoodType helpers

extension FoodType {
    var displayLabel: String {
        switch self {
        case .vegetarian:    return "Veg"
        case .nonVegetarian: return "Non-Veg"
        case .vegan:         return "Vegan"
        }
    }
}
