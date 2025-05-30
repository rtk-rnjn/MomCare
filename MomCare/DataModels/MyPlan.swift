//
//  MyPlan.swift
//  MomCare
//
//  Created by Ritik Ranjan on 13/01/25.
//

import Foundation
import UIKit

enum MealType: String, Codable, Equatable {
    case breakfast
    case lunch
    case snacks
    case dinner

    // MARK: Lifecycle

    init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .breakfast
        case 1: self = .lunch
        case 2: self = .snacks
        case 3: self = .dinner
        default: return nil
        }
    }
}

enum ExerciseType: String, Codable, Equatable {
    case breathing = "Breathing"
    case stretching = "Stretching"
    case yoga = "Yoga"
}

enum Difficulty: String, Codable, Equatable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

struct FoodItem: Codable, Sendable, Equatable {

    enum CodingKeys: String, CodingKey {
        case name
        case imageUri = "image_uri"
        case calories
        case protein
        case carbs
        case fat
        case sodium
        case sugar
        case consumed
    }

    let name: String
    let imageUri: String?

    var calories: Double = 0
    var protein: Double = 0
    var carbs: Double = 0
    var fat: Double = 0
    var sodium: Double = 0
    var sugar: Double = 0

    var consumed: Bool = false

    var image: UIImage? {
        get async {
            return await UIImage().fetchImage(from: imageUri)
        }
    }
}

struct MyPlan: Codable, Sendable, Equatable {
    enum CodingKeys: String, CodingKey {
        case breakfast
        case lunch
        case snacks
        case dinner
        case createdAt = "created_at"
    }

    var breakfast: [FoodItem] = []
    var lunch: [FoodItem] = []
    var snacks: [FoodItem] = []
    var dinner: [FoodItem] = []

    var createdAt: Date?

    func allMeals() -> [FoodItem] {
        return breakfast + lunch + snacks + dinner
    }

    func isEmpty() -> Bool {
        return breakfast.isEmpty && lunch.isEmpty && snacks.isEmpty && dinner.isEmpty
    }

    func isOutdated() -> Bool {
        guard let createdAt else { return false }

        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: createdAt)
        let now = Date()
        return calendar.isDate(createdAt, inSameDayAs: yesterday!) || createdAt < now
    }

    subscript(index: Int) -> [FoodItem] {
        mutating get {
            switch index {
            case 0: return breakfast
            case 1: return lunch
            case 2: return snacks
            case 3: return dinner
            default: fatalError()
            }
        }
    }

    subscript(mealtype: MealType) -> [FoodItem] {
        mutating get {
            switch mealtype {
            case .breakfast: return breakfast
            case .lunch: return lunch
            case .snacks: return snacks
            case .dinner: return dinner
            }
        }
    }
}

struct Exercise: Codable, Sendable, Equatable {
    enum CodingKeys: String, CodingKey {
        case name
        case exerciseType = "exercise_type"
        case duration
        case description
        case tags
        case level
        case exerciseImageUri = "exercise_image_name"
        case durationCompleted = "duration_completed"
    }

    var name: String
    var exerciseType: ExerciseType = .breathing
    var duration: TimeInterval
    var description: String
    var tags: [String] = []
    var level: Difficulty = .beginner
    var exerciseImageUri: String
    var durationCompleted: TimeInterval = 0

    var completed: Bool {
        return durationCompleted >= duration - 1
    }

    var completionPercentage: Double {
        return durationCompleted / duration
    }

    var exerciseImage: UIImage? {
        get async {
            return await UIImage().fetchImage(from: exerciseImageUri)
        }
    }
}
