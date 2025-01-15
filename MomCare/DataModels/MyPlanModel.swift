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
}

class UserDiet {
    private var plan: MyPlanModel?

    private var breakfast: [FoodItem] = []
    private var lunch: [FoodItem] = []
    private var dinner: [FoodItem] = []

    static var shared: UserDiet = UserDiet()
    
    private init() {
        updateFromDatabase()
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

struct Exercise {
    let exerciseType: ExerciseType
    let duration: TimeInterval
    
    let description: String
    let tags: [String]
    
    let level: String = "Beginner"
    
    var exerciseImageName: String
    var exerciseImage: UIImage? {
        return UIImage(named: exerciseImageName)
    }
    
    var durationCompleted: TimeInterval = 0
}

class UserExercise {
    private var walkingGoal: Int?
    private var stepsTaken: Int?

    private var plan: MyPlanModel?
    
    private var exercises: [Exercise] = []
    
    static var shared: UserExercise = UserExercise()
    
    private init() {
        updateFromDatabase()
    }

    func updateFromDatabase() {
    }
    
    func updateToDatabase() {
    }
}
