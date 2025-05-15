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
}

enum Difficulty: String, Codable, Equatable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

struct FoodItem: Codable, Sendable, Equatable {

    // MARK: Internal

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
    let imageUri: String

    var calories: Double = 0
    var protein: Double = 0
    var carbs: Double = 0
    var fat: Double = 0
    var sodium: Double = 0
    var sugar: Double = 0

    var consumed: Bool = false

    var image: UIImage? {
        get async {
            if let image = fetchFromFileSystem(uri: imageUri) {
                return image
            }
            guard let url = URL(string: imageUri) else { return nil }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)

                saveToFileSystem(uri: imageUri, data: data)
                return UIImage(data: data)
            } catch {
                return nil
            }
        }
    }

    // MARK: Private

    private func fetchFromFileSystem(uri: String) -> UIImage? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(uri)

        return UIImage(contentsOfFile: fileURL.path)
    }

    private func saveToFileSystem(uri: String, data: Data) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(uri)

        try? data.write(to: fileURL)
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

    func allMeals() -> [FoodItem] {
        return breakfast + lunch + snacks + dinner
    }

    func isEmpty() -> Bool {
        return breakfast.isEmpty && lunch.isEmpty && snacks.isEmpty && dinner.isEmpty
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
