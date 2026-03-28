import Foundation

extension MCContentRepository {
    nonisolated func markFoodAs(consumed: Bool, planId: String, meal: MealType, foodId: String) async throws -> NetworkResponse<Bool> {
        let url: String = if consumed {
            Endpoint.updateFoodItemConsume.urlString(with: planId, meal.rawValue, foodId)
        } else {
            Endpoint.updateFoodItemUnconsume.urlString(with: planId, meal.rawValue, foodId)
        }

        return try await MCNetworkManager.shared.get(url: url, headers: authenticationHeaders)
    }

    nonisolated func addFoodItem(toPlan planId: String, meal: MealType, foodId: String) async throws -> NetworkResponse<Bool> {
        let url = Endpoint.updateAddFoodItem.urlString(with: planId, meal.rawValue, foodId)
        return try await MCNetworkManager.shared.get(url: url, headers: authenticationHeaders)
    }

    nonisolated func removeFoodItem(fromPlan planId: String, meal: MealType, foodId: String) async throws -> NetworkResponse<Bool> {
        let url = Endpoint.updateRemoveFoodItem.urlString(with: planId, meal.rawValue, foodId)
        return try await MCNetworkManager.shared.get(url: url, headers: authenticationHeaders)
    }

    func updateExerciseCompletion(userExerciseId id: String, duration: TimeInterval) async throws -> NetworkResponse<Bool> {
        let data = try ExerciseDuration(duration: duration).encodeUsingJSONEncoder()

        return try await MCNetworkManager.shared.post(url: Endpoint.updateExerciseDuration.urlString(with: id), body: data, headers: authenticationHeaders)
    }
}
