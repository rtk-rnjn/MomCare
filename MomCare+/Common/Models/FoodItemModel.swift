//
//  FoodItemModel.swift
//  MomCare+
//
//  Created by Aryan singh on 12/02/26.
//

import Foundation
import UIKit

enum FoodType: String, Codable, Hashable {
    case vegetarian = "veg"
    case nonVegetarian = "non-veg"
    case vegan
}

struct FoodItemModel: Equatable, Hashable, Identifiable, Sendable, Codable, CustomStringConvertible {
    enum CodingKeys: String, CodingKey {
        case _id
        case name
        case state
        case type
        case allergicIngredients = "allergic_ingredients"
        case totalCalories = "total_calories"
        case totalCarbsInGrams = "total_carbs_in_g"
        case totalFatsInGrams = "total_fats_in_g"
        case totalProteinInGrams = "total_protein_in_g"
        case totalSugarInGrams = "total_sugar_in_g"
        case totalSodiumInMiligrams = "total_sodium_in_mg"
        case vitaminContent = "vitamin_content"
        case imageUri = "image_uri"
    }

    var _id: String
    var name: String
    var state: IndianState
    var type: FoodType
    var allergicIngredients: [Intolerance]
    var totalCalories: Double
    var totalCarbsInGrams: Double
    var totalFatsInGrams: Double
    var totalProteinInGrams: Double
    var totalSugarInGrams: Double
    var totalSodiumInMiligrams: Double
    var vitaminContent: [String]
    var imageUri: String?

    var description: String {
        "FoodItemModel: \(id) - \(name)"
    }

    var id: String {
        _id
    }

    var image: UIImage? {
        get async {
            if let imageUri {
                return try? await UIImage.getOrFetch(from: imageUri)
            }
            return nil
        }
    }
}

extension FoodItemModel {
    var calories: Measurement<UnitEnergy> {
        Measurement(value: totalCalories,
                    unit: .kilocalories)
    }

    var sodium: Measurement<UnitMass> {
        Measurement(value: totalSodiumInMiligrams,
                    unit: .milligrams)
    }

    var protein: Measurement<UnitMass> {
        Measurement(value: totalProteinInGrams,
                    unit: .grams)
    }

    var carbs: Measurement<UnitMass> {
        Measurement(value: totalCarbsInGrams,
                    unit: .grams)
    }

    var fats: Measurement<UnitMass> {
        Measurement(value: totalFatsInGrams,
                    unit: .grams)
    }

    var sugar: Measurement<UnitMass> {
        Measurement(value: totalSugarInGrams,
                    unit: .grams)
    }
}
