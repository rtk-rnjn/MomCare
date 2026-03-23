enum MyPlanModelReferenceType {
    case user
    case server
}

extension MealPlanModel {
    func fetchFoods(for references: [FoodReferenceModel]) async -> [FoodItemModel] {
        await withTaskGroup(of: FoodItemModel?.self) { group in
            for reference in references {
                group.addTask {
                    await reference.food
                }
            }

            var foods = [FoodItemModel]()
            for await food in group {
                if let food {
                    foods.append(food)
                }
            }
            return foods
        }
    }

    func targetNutrition(of references: MyPlanModelReferenceType = .user) async -> NutritionTotals {
        let foods = await fetchFoods(for: references == .user ? allReferences : originalReferences)
        return foods.reduce(.zero) { result, food in
            NutritionTotals(
                calories: result.calories + food.totalCalories,
                carbs: result.carbs + food.totalCarbsInGrams,
                fats: result.fats + food.totalFatsInGrams,
                protein: result.protein + food.totalProteinInGrams,
                sugar: result.sugar + food.totalSugarInGrams,
                sodium: result.sodium + food.totalSodiumInMiligrams
            )
        }
    }

    func consumedNutrition() async -> NutritionTotals {
        let foods = await fetchFoods(for: consumedReferences)
        return foods.reduce(.zero) { result, food in
            NutritionTotals(
                calories: result.calories + food.totalCalories,
                carbs: result.carbs + food.totalCarbsInGrams,
                fats: result.fats + food.totalFatsInGrams,
                protein: result.protein + food.totalProteinInGrams,
                sugar: result.sugar + food.totalSugarInGrams,
                sodium: result.sodium + food.totalSodiumInMiligrams
            )
        }
    }
}
