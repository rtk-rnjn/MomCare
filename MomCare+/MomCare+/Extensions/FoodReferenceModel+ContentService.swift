extension FoodReferenceModel {
    var food: FoodItemModel? {
        get async {
            let networkResponse = try? await MCContentRepository.shared.getOrFetchFoodItem(id: foodId)
            return networkResponse?.data
        }
    }
}
