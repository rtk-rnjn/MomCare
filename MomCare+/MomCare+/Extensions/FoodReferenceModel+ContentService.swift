extension FoodReferenceModel {
    var food: FoodItemModel? {
        get async {
            let networkResponse = try? await ContentRepository.shared.getOrFetchFoodItem(id: foodId)
            return networkResponse?.data
        }
    }
}
