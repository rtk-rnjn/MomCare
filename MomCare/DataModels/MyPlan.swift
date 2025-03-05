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
}

enum ExerciseType: String, Codable, Equatable {
    case breathing = "Breathing"
    case stretching = "Stretching"
}

enum Difficulty: String, Codable, Equatable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

struct FoodItem: Codable, Sendable, Equatable {
    enum CodingKeys: String, CodingKey {
        case name
        case imageName = "image_name"
        case calories
        case protein
        case carbs
        case fat
        case sodium
        case sugar
        case consumed
    }

    let name: String
    let imageName: String
    var calories: Int = 0
    var protein: Int = 0
    var carbs: Int = 0
    var fat: Int = 0
    var sodium: Int = 0
    var sugar: Int = 0
    var consumed: Bool = false

    var image: UIImage? {
        return UIImage(named: imageName)
    }
}

struct MyPlan: Codable, Sendable, Equatable {
    enum CodingKeys: String, CodingKey {
        case breakfast
        case lunch
        case snacks
        case dinner
    }

    var breakfast: [FoodItem] = []
    var lunch: [FoodItem] = []
    var snacks: [FoodItem] = []
    var dinner: [FoodItem] = []
}

struct Exercise: Codable, Sendable, Equatable {
    enum CodingKeys: String, CodingKey {
        case exerciseType = "exercise_type"
        case duration
        case description
        case tags
        case level
        case exerciseImageName = "exercise_image_name"
        case durationCompleted = "duration_completed"
    }

    let exerciseType: ExerciseType
    let duration: TimeInterval
    let description: String
    let tags: [String]
    var level: Difficulty = .beginner
    var exerciseImageName: String
    var durationCompleted: TimeInterval = 0

    var completed: Bool {
        return durationCompleted >= duration - 1
    }

    var exerciseImage: UIImage? {
        return UIImage(named: exerciseImageName)
    }
}
