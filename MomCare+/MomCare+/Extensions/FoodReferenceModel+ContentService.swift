extension FoodReferenceModel {
    var food: FoodItemModel? {
        get async {
            let networkResponse = try? await ContentService.shared.fetchFoodItem(id: foodId)
            return networkResponse?.data
        }
    }
}
