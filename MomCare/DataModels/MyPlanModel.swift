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
    let id: UUID = UUID()
    let name: String
    let imageName: String
    var image: UIImage? {
        return UIImage(named: imageName)
    }

    var calories: Int = 0
    var protein: Int = 0
    var carbs: Int = 0
    var fat: Int = 0

    var consumed: Bool = false

    init(name: String, imageName: String, calories: Int, protein: Int, carbs: Int, fat: Int) {
        self.name = name

        self.imageName = imageName
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
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
    // MomCareUser.shared.diet.plan.addFoodItem(FOODITEM, to: .breakfast)
    public private(set) var plan: MyPlanModel = MyPlanModel(caloriesGoal: 1740, proteinGoal: 70, carbsGoal: 175, fatGoal: 60)

    public private(set) var breakfast: [FoodItem] = [
        FoodItem(name: "Moong Dal Cheela", imageName: "moong-dal-cheela", calories: 120, protein: 8, carbs: 15, fat: 2),
        FoodItem(name: "Anda Bhurji", imageName: "anda-bhurji", calories: 150, protein: 12, carbs: 2, fat: 10)
    ]

    public private(set) var lunch: [FoodItem] = [
        FoodItem(name: "Chole Chawal", imageName: "chole-chawal", calories: 350, protein: 12, carbs: 50, fat: 8),
        FoodItem(name: "Aloo Matar", imageName: "aloo-matar", calories: 200, protein: 6, carbs: 30, fat: 5),
        FoodItem(name: "Amritsari Kulcha", imageName: "amritsari-kulcha", calories: 250, protein: 6, carbs: 40, fat: 8)
    ]

    public private(set) var snacks: [FoodItem] = [
        FoodItem(name: "Aloo Chaat", imageName: "aloo-chaat", calories: 180, protein: 3, carbs: 25, fat: 8),
        FoodItem(name: "Halwa", imageName: "halwa", calories: 300, protein: 4, carbs: 40, fat: 15)
    ]

    public private(set) var dinner: [FoodItem] = [
        FoodItem(name: "Aloo Paratha", imageName: "aloo-paratha", calories: 280, protein: 6, carbs: 40, fat: 10),
        FoodItem(name: "Aloo Matar", imageName: "aloo-matar", calories: 200, protein: 6, carbs: 30, fat: 5)
    ]

    static var shared: UserDiet = UserDiet()

    private init() {
        updateFromDatabase()
    }

    func addFoodItem(_ foodItem: FoodItem, to meal: MealType) {
        switch meal {
        case .breakfast:
            breakfast.append(foodItem)
        case .lunch:
            lunch.append(foodItem)
        case .snacks:
            snacks.append(foodItem)
        case .dinner:
            dinner.append(foodItem)
        }
    }

    func removeFoodItem(_ foodItem: FoodItem, from meal: MealType) {
        switch meal {
        case .breakfast:
            breakfast.removeAll { $0.id == foodItem.id }
        case .lunch:
            lunch.removeAll { $0.id == foodItem.id }
        case .snacks:
            snacks.removeAll { $0.id == foodItem.id }
        case .dinner:
            dinner.removeAll { $0.id == foodItem.id }
        }
    }

    func markFoodAsConsumed(_ foodItem: FoodItem, in meal: MealType) -> Bool {
        var multiplier = 1

        switch meal {
        case .breakfast:
            if let index = breakfast.firstIndex(where: { $0.id == foodItem.id }) {
                breakfast[index].consumed = !breakfast[index].consumed
                multiplier = breakfast[index].consumed ? 1 : -1
            }
        case .lunch:
            if let index = lunch.firstIndex(where: { $0.id == foodItem.id }) {
                lunch[index].consumed = !lunch[index].consumed
                multiplier = lunch[index].consumed ? 1 : -1
            }
        case .snacks:
            if let index = snacks.firstIndex(where: { $0.id == foodItem.id }) {
                snacks[index].consumed = !snacks[index].consumed
                multiplier = snacks[index].consumed ? 1 : -1
            }
        case .dinner:
            if let index = dinner.firstIndex(where: { $0.id == foodItem.id }) {
                dinner[index].consumed = !dinner[index].consumed
                multiplier = dinner[index].consumed ? 1 : -1
            }
        }

        self.plan.currentCaloriesIntake += foodItem.calories * multiplier
        self.plan.currentProteinIntake += foodItem.protein * multiplier
        self.plan.currentCarbsIntake += foodItem.carbs * multiplier
        self.plan.currentFatIntake += foodItem.fat * multiplier

        return multiplier == 1
    }

    func markFoodsAsConsumed(in meal: MealType) {
        switch meal {
        case .breakfast:
            for index in 0..<breakfast.count {
                markFoodAsConsumed(breakfast[index], in: .breakfast)
            }
        case .lunch:
            for index in 0..<lunch.count {
                markFoodAsConsumed(lunch[index], in: .lunch)
            }
        case .snacks:
            for index in 0..<snacks.count {
                markFoodAsConsumed(snacks[index], in: .snacks)
            }
        case .dinner:
            for index in 0..<dinner.count {
                markFoodAsConsumed(dinner[index], in: .dinner)
            }
        }
    }

    func updateFromDatabase() {

    }

    func updateToDatabase() {

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
    var exerciseImage: UIImage? {
        return UIImage(named: exerciseImageName)
    }

    var durationCompleted: TimeInterval = 0
}

class UserExercise {
    public private(set) var exercises: [Exercise] = [
        .init(exerciseType: .breathing, duration: 60, description: "Breathing exercise", tags: ["breathing"], exerciseImageName: "breathing")
    ]
    static var shared: UserExercise = UserExercise()

    private init() {
        updateFromDatabase()
    }

    func updateFromDatabase() {

    }

    func updateToDatabase() {

    }
}
