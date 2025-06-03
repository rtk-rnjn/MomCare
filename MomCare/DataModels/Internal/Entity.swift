//
//  Database.swift
//  MomCare
//
//  Created by RITIK RANJAN on 03/06/25.
//

import RealmSwift
import Foundation
import UIKit

class Images: Object {
    @Persisted var uri: String = .init()
    @Persisted var imageData: Data = .init()

    override static func primaryKey() -> String? {
        return "uri"
    }
}

class FoodItems: Object {
    @Persisted var name: String
    @Persisted var imageUri: String?

    @Persisted var calories: Double = 0
    @Persisted var protein: Double = 0
    @Persisted var carbs: Double = 0
    @Persisted var fat: Double = 0
    @Persisted var sodium: Double = 0
    @Persisted var sugar: Double = 0

    convenience init(foodItem: FoodItem) {
        self.init()

        self.name = foodItem.name
        self.imageUri = foodItem.imageUri
        self.calories = foodItem.calories
        self.protein = foodItem.protein
        self.carbs = foodItem.carbs
        self.fat = foodItem.fat
        self.sodium = foodItem.sodium
        self.sugar = foodItem.sugar
    }
}

class Songs: Object {
    @Persisted var name: String
    @Persisted var uri: Data
}
