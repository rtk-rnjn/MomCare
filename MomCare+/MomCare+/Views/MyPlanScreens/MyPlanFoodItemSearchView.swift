import SwiftUI

struct MyPlanFoodItemSearchView: View {
    // MARK: Internal

    let mealType: MealType

    var body: some View {
        NavigationStack {
            foodList
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search foods…")
            .searchFocused($searchFocus)
            .onChange(of: searchText) { _, newValue in
                Task {
                    try? await debounceSearch(query: newValue)
                }
            }
            .sheet(item: $detailFoodItem) { food in
                NavigationStack {
                    NutritionDetailSheet(food: food)
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Add") {
                                    Task {
                                        await addFood(food)
                                        dismiss()
                                    }
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
            .onAppear {
                if musicHandler.isPlaying {
                    musicHandler.togglePlayPause()
                    needMusicPlayToggle = true
                }
                searchFocus = true
            }
            .onDisappear {
                if needMusicPlayToggle {
                    musicHandler.togglePlayPause()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: Private

    @FocusState private var searchFocus: Bool

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
    @EnvironmentObject private var musicHandler: MusicPlayerHandler

    @State private var needMusicPlayToggle: Bool = false
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var foodItems: [FoodItemModel] = []
    @State private var detailFoodItem: FoodItemModel?
    @State private var showErrorAlert = false
    @State private var alertMessage: String?

    private var foodList: some View {
        List(foodItems) { food in
            FoodRowView(food: food)
                .onTapGesture {
                    detailFoodItem = food
                }
                .accessibilityAction(.default) {
                    detailFoodItem = food
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button {
                        Task { await addFood(food) }
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
        .overlay {
            if searchText.isEmpty {
                ContentUnavailableView("Try Searching any Food", systemImage: "magnifyingglass")
            } else if foodItems.isEmpty {
                ContentUnavailableView.search
            }
        }
    }

    private func addFood(_ food: FoodItemModel) async {
        do {
            try await contentServiceHandler.addFoodToMyPlan(foodId: food.id, mealType: mealType)
            await MainActor.run { dismiss() }
        } catch {
            alertMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    private func debounceSearch(query: String) async throws {
        guard !query.isEmpty else {
            foodItems = []
            return
        }

        foodItems.removeAll()

        let urlString = Endpoint.searchFoodItem.urlString
        let queryParameters: [String: any Codable] = ["food_name": query, "limit": 10]

        let stream: AsyncThrowingStream<FoodItemModel, any Error> = await MCNetworkManager.shared.fetchStreamedData(.GET, url: urlString, queryParameters: queryParameters)

        for try await item in stream {
            foodItems.append(item)
            foodItems.sort { $0.name < $1.name }
        }
    }
}

private struct FoodRowView: View {
    let food: FoodItemModel

    var body: some View {
        HStack(spacing: 12) {
            FoodThumbnail(foodIdentifier: food.id)

            VStack(alignment: .leading, spacing: 3) {
                Text(food.name.capitalized)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text("\(Int(food.totalCalories)) \(UnitEnergy.kilocalories.symbol)  ·  \(food.type.displayLabel)  ·  \(food.state.rawValue.capitalized)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(food.name.capitalized), \(Int(food.totalCalories)) kilocalories, \(food.type.displayLabel)")
        .accessibilityHint("Double tap to view nutrition details")
    }
}

private struct NutritionDetailSheet: View {
    // MARK: Internal

    let food: FoodItemModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 14) {
                AsyncImage(url: URL(string: food.imageUri ?? "")) { phase in
                    switch phase {
                    case let .success(image):
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
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(food.name.capitalized), \(food.type.displayLabel)")

            Divider()
                .padding(.horizontal, 20)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 1) {
                NutritionCell(label: "Calories", value: "\(Int(food.totalCalories))", unit: UnitEnergy.kilocalories.symbol)
                NutritionCell(label: "Protein", value: format(food.totalProteinInGrams), unit: UnitMass.grams.symbol)
                NutritionCell(label: "Carbs", value: format(food.totalCarbsInGrams), unit: UnitMass.grams.symbol)
                NutritionCell(label: "Fats", value: format(food.totalFatsInGrams), unit: UnitMass.grams.symbol)
                NutritionCell(label: "Sugar", value: format(food.totalSugarInGrams), unit: UnitMass.grams.symbol)
                NutritionCell(label: "Sodium", value: format(food.totalSodiumInMiligrams), unit: UnitMass.milligrams.symbol)
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

    // MARK: Private

    @Environment(\.dismiss) private var dismiss

    private func format(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(1)))
    }
}

private struct NutritionCell: View {
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label), \(value) \(unit)")
    }
}
