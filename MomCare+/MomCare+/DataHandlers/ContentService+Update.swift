import Foundation

extension ContentService {
    func markFoodAs(consumed: Bool, planId: String, meal: MealType, foodId: String) async throws -> NetworkResponse<Bool> {
        DebugLogger.shared.log("Marking food \(foodId) as \(consumed ? "consumed" : "unconsumed") in \(meal.rawValue) for plan \(planId)", level: .debug, category: .data)
        let url: String = if consumed {
            Endpoint.updateFoodItemConsume.urlString(with: planId, meal.rawValue, foodId)
        } else {
            Endpoint.updateFoodItemUnconsume.urlString(with: planId, meal.rawValue, foodId)
        }
        await CacheHandler.shared.invalidate(forKey: "mealPlan")
        return try await NetworkManager.shared.get(url: url, headers: AuthenticationService.authorizationHeaders)
    }

    func addFoodItem(toPlan planId: String, meal: MealType, foodId: String) async throws -> NetworkResponse<Bool> {
        DebugLogger.shared.log("Adding food \(foodId) to \(meal.rawValue) in plan \(planId)", level: .debug, category: .data)
        let url = Endpoint.updateAddFoodItem.urlString(with: planId, meal.rawValue, foodId)
        await CacheHandler.shared.invalidate(forKey: "mealPlan")
        return try await NetworkManager.shared.get(url: url, headers: AuthenticationService.authorizationHeaders)
    }

    func removeFoodItem(fromPlan planId: String, meal: MealType, foodId: String) async throws -> NetworkResponse<Bool> {
        DebugLogger.shared.log("Removing food \(foodId) from \(meal.rawValue) in plan \(planId)", level: .debug, category: .data)
        let url = Endpoint.updateRemoveFoodItem.urlString(with: planId, meal.rawValue, foodId)
        await CacheHandler.shared.invalidate(forKey: "mealPlan")
        return try await NetworkManager.shared.get(url: url, headers: AuthenticationService.authorizationHeaders)
    }

    func updateExerciseCompletion(userExerciseId id: String, duration: TimeInterval) async throws -> NetworkResponse<Bool> {
        DebugLogger.shared.log("Updating exercise completion: id=\(id), duration=\(duration)s", level: .debug, category: .data)
        let url = Endpoint.updateExerciseDuration.urlString(with: id)
        let exerciseDuration = ExerciseDuration(duration: duration)
        guard let data = exerciseDuration.encodeUsingJSONEncoder() else {
            fatalError()
        }
        return try await NetworkManager.shared.post(url: url, body: data, headers: AuthenticationService.authorizationHeaders)
    }
}
