extension FoodReferenceModel {
    var food: FoodItemModel? {
        get async {
            let networkResponse = try? await ContentRepository.shared.fetchFoodItem(id: foodId)
            return networkResponse?.data
        }
    }
}
