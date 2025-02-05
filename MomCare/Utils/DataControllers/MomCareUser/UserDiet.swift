extension MomCareUser {

    func addFoodItem(_ foodItem: FoodItem, to meal: MealType) {
        meals[meal]?.append(foodItem)
    }

    func removeFoodItem(_ foodItem: FoodItem, from meal: MealType) {
        meals[meal]?.removeAll { $0.id == foodItem.id }
    }

    func markFoodAsConsumed(_ foodItem: FoodItem, in meal: MealType) -> Bool {
        guard let index = meals[meal]?.firstIndex(where: { $0.id == foodItem.id }) else { return false }

        meals[meal]?[index].consumed.toggle()
        let multiplier = meals[meal]?[index].consumed == true ? 1 : -1

        updatePlan(with: foodItem, multiplier: multiplier)
        return multiplier == 1
    }

    func markFoodsAsConsumed(in meal: MealType) {
        meals[meal]?.forEach { _ = markFoodAsConsumed($0, in: meal) }
    }

    // MARK: Private

    private func updatePlan(with foodItem: FoodItem, multiplier: Int) {
        user?.plan?.currentCaloriesIntake += foodItem.calories * multiplier
        user?.plan?.currentProteinIntake += foodItem.protein * multiplier
        user?.plan?.currentCarbsIntake += foodItem.carbs * multiplier
        user?.plan?.currentFatIntake += foodItem.fat * multiplier
    }

}
