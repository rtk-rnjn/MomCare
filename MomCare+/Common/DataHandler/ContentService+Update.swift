//
//  ContentService+Update.swift
//  MomCare+
//
//  Created by Aryan singh on 16/02/26.
//

import Foundation

enum MealType: String, Codable {
    case breakfast
    case lunch
    case dinner
    case snacks
}

extension ContentService {
    func markFoodAs(consumed: Bool, planId: String, meal: MealType, foodId: String) async throws -> NetworkResponse<Bool> {
        let url: String = if consumed {
            Endpoint.updateFoodItemConsume.urlString(with: planId, meal.rawValue, foodId)
        } else {
            Endpoint.updateFoodItemUnconsume.urlString(with: planId, meal.rawValue, foodId)
        }
        await CacheHandler.shared.invalidate(forKey: "mealPlan")
        return try await NetworkManager.shared.get(url: url, headers: AuthenticationService.authorizationHeaders)
    }

    func addFoodItem(toPlan planId: String, meal: MealType, foodId: String) async throws -> NetworkResponse<Bool> {
        let url = Endpoint.updateAddFoodItem.urlString(with: planId, meal.rawValue, foodId)
        await CacheHandler.shared.invalidate(forKey: "mealPlan")
        return try await NetworkManager.shared.get(url: url, headers: AuthenticationService.authorizationHeaders)
    }

    func removeFoodItem(fromPlan planId: String, meal: MealType, foodId: String) async throws -> NetworkResponse<Bool> {
        let url = Endpoint.updateRemoveFoodItem.urlString(with: planId, meal.rawValue, foodId)
        await CacheHandler.shared.invalidate(forKey: "mealPlan")
        return try await NetworkManager.shared.get(url: url, headers: AuthenticationService.authorizationHeaders)
    }

    func updateExerciseCompletion(exerciseId id: String, duration: TimeInterval) async throws -> NetworkResponse<Bool> {
        let url = Endpoint.updateExerciseDuration.urlString(with: id)
        let exerciseDuration = ExerciseDuration(duration: duration)
        guard let data = exerciseDuration.encodeUsingJSONEncoder() else {
            fatalError()
        }
        return try await NetworkManager.shared.post(url: url, body: data, headers: AuthenticationService.authorizationHeaders)
    }
}
