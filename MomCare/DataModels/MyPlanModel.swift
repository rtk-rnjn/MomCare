//
//  MyPlanModel.swift
//  MomCare
//
//  Created by Ritik Ranjan on 13/01/25.
//

import Foundation

// MARK: Diet

struct FoodItem {
    let id: Int
    let name: String
    
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
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
    
    var breakfast: [FoodItem] = []
    var lunch: [FoodItem] = []
    var dinner: [FoodItem] = []
}

class UserDiet {
    private var plan: MyPlanModel?
    
    static var shared: UserDiet = UserDiet()
    
    private init() {
        updateFromDatabase()
    }

    func updateFromDatabase() {
    }
}

// MARK: Exercise

enum ExerciseType: String {
    case breathing
    case stretching
}

struct Exercise {
    let exerciseType: ExerciseType
    let duration: TimeInterval
    
    let description: String
    let tags: [String]
    
    let level: String = "Beginner"
}

class UserExercise {
    private var walkingGoal: Int?
    private var stepsTaken: Int?

    private var plan: MyPlanModel?
    
    static var shared: UserExercise = UserExercise()
    
    private init() {
        updateFromDatabase()
    }

    func updateFromDatabase() {
    }
}
