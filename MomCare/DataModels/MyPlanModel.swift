//
//  MyPlanModel.swift
//  MomCare
//
//  Created by Ritik Ranjan on 13/01/25.
//

import Foundation
import UIKit

// MARK: Diet

struct FoodItem {

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

    let id: UUID = .init()
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

struct MyPlanModel {
    let caloriesGoal: Int?
    let proteinGoal: Int?
    let carbsGoal: Int?
    let fatGoal: Int?

    var currentCaloriesIntake: Int = 0
    var currentProteinIntake: Int = 0
    var currentCarbsIntake: Int = 0
    var currentFatIntake: Int = 0
}

public enum MealType: Hashable {
    case breakfast
    case lunch
    case snacks
    case dinner
}

class UserDiet {

    // MARK: Lifecycle

    private init() {
        updateFromDatabase()
    }

    // MARK: Public

    public private(set) var plan: MyPlanModel = .init(caloriesGoal: 1740, proteinGoal: 70, carbsGoal: 175, fatGoal: 60)

    // MARK: Internal

    static var shared: UserDiet = .init()

    var meals: [MealType: [FoodItem]] = [
        .breakfast: [
            FoodItem(name: "Moong Dal Cheela", imageName: "moong-dal-cheela", calories: 120, protein: 8, carbs: 15, fat: 2),
            FoodItem(name: "Anda Bhurji", imageName: "anda-bhurji", calories: 150, protein: 12, carbs: 2, fat: 10)
        ],
        .lunch: [
            FoodItem(name: "Chole Chawal", imageName: "chole-chawal", calories: 350, protein: 12, carbs: 50, fat: 8),
            FoodItem(name: "Aloo Matar", imageName: "aloo-matar", calories: 200, protein: 6, carbs: 30, fat: 5),
            FoodItem(name: "Amritsari Kulcha", imageName: "amritsari-kulcha", calories: 250, protein: 6, carbs: 40, fat: 8)
        ],
        .snacks: [
            FoodItem(name: "Aloo Chaat", imageName: "aloo-chaat", calories: 180, protein: 3, carbs: 25, fat: 8),
            FoodItem(name: "Halwa", imageName: "halwa", calories: 300, protein: 4, carbs: 40, fat: 15)
        ],
        .dinner: [
            FoodItem(name: "Aloo Paratha", imageName: "aloo-paratha", calories: 280, protein: 6, carbs: 40, fat: 10),
            FoodItem(name: "Aloo Matar", imageName: "aloo-matar", calories: 200, protein: 6, carbs: 30, fat: 5)
        ]
    ]

    func addFoodItem(_ foodItem: FoodItem, to meal: MealType) {
        meals[meal]?.append(foodItem)
    }

    func removeFoodItem(_ foodItem: FoodItem, from meal: MealType) {
        meals[meal]?.removeAll { $0.id == foodItem.id }
    }

    func markFoodAsConsumed(_ foodItem: FoodItem, in meal: MealType) -> Bool {
        guard let index = meals[meal]?.firstIndex(where: { $0.id == foodItem.id }) else { return false }

        meals[meal]?[index].consumed.toggle()
        let multiplier = meals[meal]?[index].consumed == true ? 1 : -1

        updatePlan(with: foodItem, multiplier: multiplier)
        return multiplier == 1
    }

    func markFoodsAsConsumed(in meal: MealType) {
        meals[meal]?.forEach { _ = markFoodAsConsumed($0, in: meal) }
    }

    func updateFromDatabase() {}
    func updateToDatabase() {}

    // MARK: Private

    private func updatePlan(with foodItem: FoodItem, multiplier: Int) {
        plan.currentCaloriesIntake += foodItem.calories * multiplier
        plan.currentProteinIntake += foodItem.protein * multiplier
        plan.currentCarbsIntake += foodItem.carbs * multiplier
        plan.currentFatIntake += foodItem.fat * multiplier
    }

}

// MARK: Exercise

enum ExerciseType: String {
    case breathing
    case stretching
}

enum Difficulty: String {
    case beginner
    case intermediate
    case advanced
}

struct Exercise {
    let exerciseType: ExerciseType

    let duration: TimeInterval
    let description: String

    let tags: [String]
    let level: Difficulty = .beginner

    var exerciseImageName: String
    var durationCompleted: TimeInterval = 0

    var exerciseImage: UIImage? {
        return UIImage(named: exerciseImageName)
    }
}

class UserExercise {

    // MARK: Lifecycle

    private init() {
        updateFromDatabase()
    }

    // MARK: Public

    public private(set) var exercises: [Exercise] = []

    // MARK: Internal

    static var shared: UserExercise = .init()

    func updateFromDatabase() {}

    func updateToDatabase() {}
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
