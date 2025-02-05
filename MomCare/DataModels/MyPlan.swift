//
//  MyPlanModel.swift
//  MomCare
//
//  Created by Ritik Ranjan on 13/01/25.
//

import Foundation
import UIKit

public enum MealType: Hashable {
    case breakfast
    case lunch
    case snacks
    case dinner
}

enum ExerciseType: String, Codable {
    case breathing
    case stretching
}

enum Difficulty: String, Codable {
    case beginner
    case intermediate
    case advanced
}

struct FoodItem: Codable {

    // MARK: Lifecycle

    init(name: String, imageName: String, calories: Int, protein: Int, carbs: Int, fat: Int) {
        self.name = name

        self.imageName = imageName
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
    }

    // MARK: Internal

    var id: UUID = .init()
    let name: String
    let imageName: String
    var calories: Int = 0
    var protein: Int = 0
    var carbs: Int = 0
    var fat: Int = 0

    var consumed: Bool = false

    var image: UIImage? {
        return UIImage(named: imageName)
    }

}

struct MyPlan: Codable {
    let caloriesGoal: Int?
    let proteinGoal: Int?
    let carbsGoal: Int?
    let fatGoal: Int?

    var currentCaloriesIntake: Int = 0
    var currentProteinIntake: Int = 0
    var currentCarbsIntake: Int = 0
    var currentFatIntake: Int = 0
}

struct Exercise: Codable {
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

// MARK: Sample Data

enum SampleFoodData {
    public static var uniqueFoodItems: [FoodItem] = [
        FoodItem(name: "Moong Dal Cheela", imageName: "moong-dal-cheela", calories: 120, protein: 8, carbs: 15, fat: 2),
        FoodItem(name: "Anda Bhurji", imageName: "anda-bhurji", calories: 150, protein: 12, carbs: 2, fat: 10),
        FoodItem(name: "Chole Chawal", imageName: "chole-chawal", calories: 350, protein: 12, carbs: 50, fat: 8),
        FoodItem(name: "Aloo Matar", imageName: "aloo-matar", calories: 200, protein: 6, carbs: 30, fat: 5),
        FoodItem(name: "Amritsari Kulcha", imageName: "amritsari-kulcha", calories: 250, protein: 6, carbs: 40, fat: 8),
        FoodItem(name: "Aloo Chaat", imageName: "aloo-chaat", calories: 180, protein: 3, carbs: 25, fat: 8),
        FoodItem(name: "Halwa", imageName: "halwa", calories: 300, protein: 4, carbs: 40, fat: 15),
        FoodItem(name: "Aloo Paratha", imageName: "aloo-paratha", calories: 280, protein: 6, carbs: 40, fat: 10)
    ]
}
