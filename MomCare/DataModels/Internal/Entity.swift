//
//  Entity.swift
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

    // MARK: Lifecycle

    convenience init(foodItem: FoodItem) {
        self.init()

        name = foodItem.name
        imageUri = foodItem.imageUri
        calories = foodItem.calories
        protein = foodItem.protein
        carbs = foodItem.carbs
        fat = foodItem.fat
        sodium = foodItem.sodium
        sugar = foodItem.sugar
    }

    // MARK: Internal

    @Persisted var name: String
    @Persisted var imageUri: String?

    @Persisted var calories: Double = 0
    @Persisted var protein: Double = 0
    @Persisted var carbs: Double = 0
    @Persisted var fat: Double = 0
    @Persisted var sodium: Double = 0
    @Persisted var sugar: Double = 0

}

class Songs: Object {
    @Persisted var name: String
    @Persisted var uri: Data
}

class EKEventSymptoms: Object {
    @Persisted var eventIdentifier: String
    @Persisted var calendarItemIdentifier: String?
    @Persisted var title: String
    @Persisted var startDate: Date
    @Persisted var endDate: Date

    override static func primaryKey() -> String? {
        return "eventIdentifier"
    }
}
