import Foundation
import SwiftUI

enum MealType: String, Codable {
    case breakfast
    case lunch
    case dinner
    case snacks
}

extension MealType: CaseIterable {
    static var allCases: [MealType] {
        [.breakfast, .lunch, .dinner, .snacks]
    }

    var iconName: String {
        switch self {
        case .breakfast: "sun.horizon"
        case .lunch: "sun.max"
        case .dinner: "moon.stars"
        case .snacks: "leaf"
        }
    }

    var accentColor: Color {
        switch self {
        case .breakfast: Color(hex: "E3B34B")
        case .lunch: Color(hex: "6E8B6F")
        case .dinner: Color(hex: "A7C0CD")
        case .snacks: Color(hex: "E07B8A")
        }
    }
}

struct FoodReferenceModel: Codable, Sendable, Identifiable, Equatable {
    enum CodingKeys: String, CodingKey {
        case foodId = "food_id"
        case consumedAtTimestamp = "consumed_at_timestamp"
        case count
    }

    var foodId: String
    var consumedAtTimestamp: TimeInterval?
    var count: Int

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

struct MealPlanModel: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case _id
        case userId = "user_id"
        case breakfast
        case lunch
        case dinner
        case snacks

        // fucking hell, why i have to do this
        case originalBreakfast = "original_breakfast"
        case originalLunch = "original_lunch"
        case originalDinner = "original_dinner"
        case originalSnacks = "original_snacks"

        case createdAtTimestamp = "created_at_timestamp"
    }

    var _id: String

    var userId: String

    var breakfast: [FoodReferenceModel] = []
    var lunch: [FoodReferenceModel] = []
    var dinner: [FoodReferenceModel] = []
    var snacks: [FoodReferenceModel] = []

    var originalBreakfast: [FoodReferenceModel] = []
    var originalLunch: [FoodReferenceModel] = []
    var originalDinner: [FoodReferenceModel] = []
    var originalSnacks: [FoodReferenceModel] = []

    var createdAtTimestamp: TimeInterval = Date().timeIntervalSince1970

    subscript(_ type: MealType) -> [FoodReferenceModel] {
        get {
            switch type {
            case .breakfast: breakfast
            case .lunch: lunch
            case .dinner: dinner
            case .snacks: snacks
            }
        }
        set {
            switch type {
            case .breakfast: breakfast = newValue
            case .lunch: lunch = newValue
            case .dinner: dinner = newValue
            case .snacks: snacks = newValue
            }
        }
    }
}

extension MealPlanModel {
    var allReferences: [FoodReferenceModel] {
        breakfast + lunch + dinner + snacks
    }

    var originalReferences: [FoodReferenceModel] {
        originalBreakfast + originalLunch + originalDinner + originalSnacks
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
