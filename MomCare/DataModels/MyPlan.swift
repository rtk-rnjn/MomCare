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

    var serving: String {
        return "1 serving"
        // TODO: Implement serving size logic
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

    var totalProtien: Double {
        return allMeals().reduce(0) { $0 + $1.protein }
    }

    var totalCalories: Double {
        return allMeals().reduce(0) { $0 + $1.calories }
    }

    var totalCarbs: Double {
        return allMeals().reduce(0) { $0 + $1.carbs }
    }

    var totalFat: Double {
        return allMeals().reduce(0) { $0 + $1.fat }
    }

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
        case type = "exercise_type"
        case duration
        case description
        case tags
        case level
        case week
        case targetedBodyParts = "targeted_body_parts"
        case durationCompleted = "duration_completed"
        case assignedAt = "assigned_at"
    }

    var id: String = UUID().uuidString

    var name: String
    var type: ExerciseType
    var duration: TimeInterval?
    var description: String
    var tags: [String] = []
    var level: Difficulty = .beginner
    var week: String
    var targetedBodyParts: [String] = []
    var durationCompleted: TimeInterval = 0

    var assignedAt: Date

    var exerciseHardCodedImage: String = "Yoga1" // TODO: remove this

    var isCompleted: Bool {
        if let duration, duration > 0 {
            return durationCompleted >= duration
        }
        return false
    }

    var completionPercentage: Double {
        if type == .breathing {
            let value: Double? = Utils.get(fromKey: "BreathingCompletionDuration")
            return value ?? 0.0
        }
        guard let duration, duration > 0 else { return 0 }
        guard !duration.isNaN || !duration.isInfinite else { return 0 }

        let percentage = (durationCompleted / duration) * 100
        let boundedPercentage = min(max(percentage, 0), 100)
        return round(boundedPercentage * 100) / 100.0
    }

    var exerciseImage: UIImage? {
        get async {
            return nil
        }
    }

    var uri: String? {
        get async {
            let fileName = name.replacingOccurrences(of: " ", with: "_").lowercased().replacingOccurrences(of: "'", with: "")
            let s3Response: S3Response? = await ContentHandler.shared.fetchS3File("Exercises/\(fileName).mp4")
            return s3Response?.uri
        }
    }

    var humanReadableDuration: String {
        guard let duration else { return "0s" }

        if duration.isNaN || duration.isInfinite {
            return "0s"
        }
        if duration < 0 {
            return "0s"
        }

        let seconds = Int(duration) % 60
        let minutes = (Int(duration) / 60) % 60
        let hours = Int(duration) / 3600

        if hours > 0 {
            return "\(hours)h \(minutes)min \(seconds)sec"
        } else if minutes > 0 {
            return "\(minutes)min \(seconds)sec"
        } else {
            return "\(seconds)sec"
        }
    }
}
