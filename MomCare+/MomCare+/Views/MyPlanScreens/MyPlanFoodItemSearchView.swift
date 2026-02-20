import SwiftUI

struct MyPlanFoodItemSearchView: View {

    // MARK: Internal

    @State var mealType: MealType

    var body: some View {
        NavigationStack {
            ZStack {
                if foodItems.isEmpty, !searchText.isEmpty, !isLoading {
                    emptyStateView
                }

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(foodItems)) { food in
                            FoodRowView(food: food) {
                                selectedFoodItem = food
                                showAlert = true
                            }
                        }
                    }
                    .padding()
                }

                if isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                }
            }
            .navigationTitle("Search Food")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText)
            .onChange(of: searchText) { _, newValue in
                debounceSearch(query: newValue)
            }
            .alert("Add Food?", isPresented: $showAlert) {
                Button("Add", role: .none) {
                    Task {
                        try? await healthKitHandler.addFoodToMyPlan(foodId: selectedFoodItem?.id ?? "", mealType: mealType)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                if let selectedFoodItem {
                    Text("Do you want to add \(selectedFoodItem.name) to your plan?")
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                        task?.cancel()
                    }
                }
            }
        }
    }

    var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "fork.knife")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("No food found")
                .font(.headline)

            Text("Try searching something else")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: Private

    @EnvironmentObject private var healthKitHandler: HealthKitHandler

    @State private var selectedFoodItem: FoodItemModel?
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var foodItems: Set<FoodItemModel> = []
    @State private var isLoading = false
    @State private var task: URLSessionDataTask?
    @State private var showAlert: Bool = false

    private func debounceSearch(query: String) {
        guard !query.isEmpty else {
            foodItems = []
            return
        }

        task?.cancel()
        isLoading = true
        foodItems.removeAll()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            task = NetworkManager.shared.fetchStreamedData(
                .GET,
                url: Endpoint.searchFoodItem.urlString,
                queryParameters: ["food_name": query, "limit": 10],
                headers: nil
            ) { (food: FoodItemModel) in
                DispatchQueue.main.async {
                    foodItems.insert(food)
                    isLoading = false
                }
            }
        }
    }
}

struct FoodRowView: View {
    let food: FoodItemModel
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                AsyncImage(url: URL(string: food.imageUri ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 6) {
                    Text(food.name.capitalized)
                        .font(.headline)

                    Text("\(Int(food.totalCalories)) kcal • \(food.type.rawValue.capitalized)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5)
            )
        }
        .buttonStyle(.plain)
    }
}
