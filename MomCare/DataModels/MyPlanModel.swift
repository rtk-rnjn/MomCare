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

    let calories: Int = 0
    let protein: Int = 0
    let carbs: Int = 0
    let fat: Int = 0
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
    public private(set) var walkingGoal: Int?
    public private(set) var stepsTaken: Int?
    public private(set) var plan: MyPlanModel?
    public private(set) var exercises: [Exercise] = []
    static var shared: UserExercise = UserExercise()

    private init() {
        updateFromDatabase()
    }

    func updateFromDatabase() {

    }

    func updateToDatabase() {

    }
}
