//
//  MyPlanModel.swift
//  MomCare+
//
//  Created by Aryan singh on 12/02/26.
//

import Foundation

struct FoodReferenceModel: Codable, Sendable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case foodId = "food_id"
        case consumedAtTimestamp = "consumed_at_timestamp"
        case count
    }

    var foodId: String
    var consumedAtTimestamp: TimeInterval?
    var count: Int

    var food: FoodItemModel? {
        get async {
            let networkResponse = try? await ContentService.shared.fetchFoodItem(id: foodId)
            return networkResponse?.data
        }
    }

    var isConsumed: Bool {
        (consumedAtTimestamp ?? 0) > 0
    }

    var id: String {
        foodId
    }

    mutating func toggleConsume() {
        if isConsumed {
            consumedAtTimestamp = nil
            return
        }
        consumedAtTimestamp = Date().timeIntervalSince1970
    }
}

struct MyPlanModel: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case _id
        case userId = "user_id"
        case breakfast
        case lunch
        case dinner
        case snacks
        case createdAtTimestamp = "created_at_timestamp"
    }

    var _id: String

    var userId: String

    var breakfast: [FoodReferenceModel]
    var lunch: [FoodReferenceModel]
    var dinner: [FoodReferenceModel]
    var snacks: [FoodReferenceModel]

    var createdAtTimestamp: TimeInterval
}

extension MyPlanModel {
    var allReferences: [FoodReferenceModel] {
        breakfast + lunch + dinner + snacks
    }

    var consumedReferences: [FoodReferenceModel] {
        allReferences.filter(\.isConsumed)
    }
}

struct NutritionTotals: Sendable {
    static let zero: NutritionTotals = .init(
        calories: 0,
        carbs: 0,
        fats: 0,
        protein: 0,
        sugar: 0,
        sodium: 0
    )

    let calories: Double
    let carbs: Double
    let fats: Double
    let protein: Double
    let sugar: Double
    let sodium: Double

}

extension NutritionTotals {
    var energy: Measurement<UnitEnergy> {
        Measurement(value: calories, unit: .kilocalories)
    }

    var carbsMass: Measurement<UnitMass> {
        Measurement(value: carbs, unit: .grams)
    }

    var fatsMass: Measurement<UnitMass> {
        Measurement(value: fats, unit: .grams)
    }

    var proteinMass: Measurement<UnitMass> {
        Measurement(value: protein, unit: .grams)
    }

    var sugarMass: Measurement<UnitMass> {
        Measurement(value: sugar, unit: .grams)
    }

    var sodiumMass: Measurement<UnitMass> {
        Measurement(value: sodium, unit: .milligrams)
    }
}

extension MyPlanModel {
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

    func targetNutrition() async -> NutritionTotals {
        let foods = await fetchFoods(for: allReferences)
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
