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
            breakfast.removeAll { $0.id == foodItem.id || $0.name == foodItem.name }
        case .lunch:
            lunch.removeAll { $0.id == foodItem.id || $0.name == foodItem.name }
        case .snacks:
            snacks.removeAll { $0.id == foodItem.id || $0.name == foodItem.name }
        case .dinner:
            dinner.removeAll { $0.id == foodItem.id || $0.name == foodItem.name }
        }
    }
    
    func markFoodAsConsumed(_ foodItem: FoodItem, in meal: MealType) {
        switch meal {
        case .breakfast:
            if let index = breakfast.firstIndex(where: { $0.id == foodItem.id || $0.name == foodItem.name }) {
                breakfast[index].consumed = true
            }
        case .lunch:
            if let index = lunch.firstIndex(where: { $0.id == foodItem.id || $0.name == foodItem.name }) {
                lunch[index].consumed = true
            }
        case .snacks:
            if let index = snacks.firstIndex(where: { $0.id == foodItem.id || $0.name == foodItem.name }) {
                snacks[index].consumed = true
            }
        case .dinner:
            if let index = dinner.firstIndex(where: { $0.id == foodItem.id || $0.name == foodItem.name }) {
                dinner[index].consumed = true
            }
        }

        self.plan.currentCaloriesIntake += foodItem.calories
        self.plan.currentProteinIntake += foodItem.protein
        self.plan.currentCarbsIntake += foodItem.carbs
        self.plan.currentFatIntake += foodItem.fat
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
        .init(exerciseType: .breathing, duration: 60, description: "Breathing exercise", tags: ["breathing"], exerciseImageName: "breathing"),
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
