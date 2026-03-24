import HealthKit

extension ContentServiceHandler {
    func fetchMealPlan() async throws {
        defer { isFetchingMealPlan = false }

        isFetchingMealPlan = true
        let networkResponse = try await ContentRepository.shared.generateMealPlan()

        myPlanModel = networkResponse.data

        await fetchMyPlanMeta()
    }

    func fetchMyPlanMeta() async {
        let nutritionConsumedTotals = await myPlanModel?.consumedNutrition()
        let nutritionTargetTotals = await myPlanModel?.targetNutrition(of: .user)
        let originalNutritionTargetTotals = await myPlanModel?.targetNutrition(of: .server)

        nutritionGoalTotals = nutritionTargetTotals
        nutritionIntakeTotals = nutritionConsumedTotals
        recommendedNutritionGoalTotals = originalNutritionTargetTotals
    }

    nonisolated func consumeFoodInHealthKit(_ food: FoodItemModel, consume: Bool) async throws {
        let multiplier = consume ? 1.0 : -1.0

        try await writeHealthData(quantityTypeIdentifier: .dietaryEnergyConsumed, value: food.totalCalories * multiplier, unit: .kilocalorie())
        try await writeHealthData(quantityTypeIdentifier: .dietaryProtein, value: food.totalProteinInGrams * multiplier, unit: .gram())
        try await writeHealthData(quantityTypeIdentifier: .dietaryCarbohydrates, value: food.totalCarbsInGrams * multiplier, unit: .gram())
        try await writeHealthData(quantityTypeIdentifier: .dietaryFatTotal, value: food.totalFatsInGrams * multiplier, unit: .gram())
        try await writeHealthData(quantityTypeIdentifier: .dietarySodium, value: food.totalSodiumInMiligrams * multiplier, unit: .gramUnit(with: .milli))
        try await writeHealthData(quantityTypeIdentifier: .dietarySugar, value: food.totalSugarInGrams * multiplier, unit: .gram())
    }

    func markFoodAs(consumed: Bool, in mealType: MealType, foodReference: FoodReferenceModel) async throws {
        guard let myPlanModel else {
            return
        }
        guard foodReference.isConsumed != consumed else {
            return
        }

        if let index = self.myPlanModel?[mealType].firstIndex(where: { $0.foodId == foodReference.foodId }) {
            self.myPlanModel?[mealType][index].toggleConsume()
        }

        if let food = await foodReference.food {
            try await consumeFoodInHealthKit(food, consume: consumed)
        }

        await fetchMyPlanMeta()

        _ = try await ContentRepository.shared.markFoodAs(consumed: consumed, planId: myPlanModel._id, meal: mealType, foodId: foodReference.foodId)
    }

    func markFoodsAs(consumed: Bool, mealType: MealType) async throws {
        for foodReference in myPlanModel?[mealType] ?? [] {
            Task {  // I know what I am doing.
                try await markFoodAs(consumed: consumed, in: mealType, foodReference: foodReference)
            }
        }
    }

    func addFoodToMyPlan(foodId: String, mealType: MealType) async throws {
        guard let myPlanModel else {
            return
        }

        _ = try await ContentRepository.shared.addFoodItem(toPlan: myPlanModel._id, meal: mealType, foodId: foodId)

        let foodReference = FoodReferenceModel(foodId: foodId, count: 1)
        if let index = self.myPlanModel?[mealType].firstIndex(where: { $0.foodId == foodId }) {
            self.myPlanModel?[mealType][index].count += 1
        } else {
            self.myPlanModel?[mealType].append(foodReference)
        }

        await fetchMyPlanMeta()
    }

    func removeFoodFromPlan(foodId: String, mealType: MealType) async throws {
        guard let myPlanModel else {
            return
        }

        _ = try await ContentRepository.shared.removeFoodItem(fromPlan: myPlanModel._id, meal: mealType, foodId: foodId)

        if let index = self.myPlanModel?[mealType].firstIndex(where: { $0.foodId == foodId }) {
            self.myPlanModel?[mealType].remove(at: index)
        }

        await fetchMyPlanMeta()
    }
}
