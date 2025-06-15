//
//  UserModel.swift
//  MomCare
//
//  Created by Ritik Ranjan on 13/01/25.
//

import Foundation
import UIKit

public enum PreExistingCondition: String, Codable, CaseIterable, Sendable {
    case diabetes = "Diabetes"
    case hypertension = "Hypertension"
    case pcos = "PCOS"
    case anemia = "Anemia"
    case asthma = "Asthma"
    case heartDisease = "Heart Disease"
    case kidneyDisease = "Kidney Disease"
    case none
}

public enum Intolerance: String, Codable, CaseIterable, Sendable {
    case gluten = "Gluten"
    case lactose = "Lactose"
    case egg = "Egg"
    case seafood = "Seafood"
    case soy = "Soy"
    case dairy = "Dairy"
    case wheat = "Wheat"
    case none
}

public enum DietaryPreference: String, Codable, CaseIterable, Sendable {
    case vegetarian = "Vegetarian"
    case nonVegetarian = "Non-Vegetarian"
    case vegan = "Vegan"
    case pescetarian = "Pescetarian"
    case flexitarian = "Flexitarian"
    case glutenFree = "Gluten-Free"
    case ketogenic = "Ketogenic"
    case highProtein = "High Protein"
    case dairyFree = "Dairy-Free"
    case none
}

enum HealthProfileType: String {
    case preExistingCondition
    case intolerance
    case dietaryPreference
}

public enum MoodType: String, Codable, Sendable {
   case happy = "Happy"
   case sad = "Sad"
   case stressed = "Stressed"
   case angry = "Angry"
}

struct MoodHistory: Codable, Sendable, Equatable {
    var date: Date = .init()
    var mood: MoodType
}

struct User: Codable, Sendable, Equatable {
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case emailAddress = "email_address"
        case password
        case countryCode = "country_code"
        case country
        case phoneNumber = "phone_number"
        case medicalData = "medical_data"
        case moodHistory = "mood_history"
        case plan
        case exercises
        case history
    }

    var id: String = UUID().uuidString

    var firstName: String
    var lastName: String?

    var emailAddress: String
    var password: String

    var countryCode: String = "91"
    var country: String = "India"

    var phoneNumber: String
    var medicalData: UserMedical?

    var moodHistory: [MoodHistory] = []

    var plan: MyPlan = .init()
    var exercises: [Exercise] = []
    var history: [History] = []

    var fullName: String {
        let fullName = "\(firstName) \(lastName ?? "")"
        return fullName.trimmingCharacters(in: .whitespaces)
    }

    var pregancyData: (week: Int, day: Int, trimester: String)? { // swiftlint:disable:this large_tuple
        return Utils.pregnancyWeekAndDay(dueDate: medicalData?.dueDate ?? .init())
    }

    var lastMood: MoodType? {
        return moodHistory.sorted(by: { $0.date > $1.date }).first?.mood
    }

    var totalExercisesSeconds: Double {
        return exercises.reduce(0) { $0 + ($1.duration ?? 0) }
    }

    var totalExercisesDurationComplete: Double {
        return exercises.reduce(0) { $0 + ($1.durationCompleted) }
    }
}

struct History: Codable, Sendable, Equatable {
    enum CodingKeys: String, CodingKey {
        case date
        case plan
        case exercises
        case moods
    }

    var date: Date = .init()
    var plan: MyPlan?
    var exercises: [Exercise] = []
    var moods: [MoodHistory] = []

    var completionPercentage: Double {
        return exercises.map { $0.completionPercentage }.reduce(0, +) / Double(exercises.count)
    }
}

struct UserMedical: Codable, Sendable, Equatable {
    enum CodingKeys: String, CodingKey {
        case dateOfBirth = "date_of_birth"
        case height
        case prePregnancyWeight = "pre_pregnancy_weight"
        case currentWeight = "current_weight"
        case dueDate = "due_date"
        case preExistingConditions = "pre_existing_conditions"
        case foodIntolerances = "food_intolerances"
        case dietaryPreferences = "dietary_preferences"
    }

    var dateOfBirth: Date = .init()
    var height: Double
    var prePregnancyWeight: Double
    var currentWeight: Double
    var dueDate: Date?
    var preExistingConditions: [PreExistingCondition] = []
    var foodIntolerances: [Intolerance] = []
    var dietaryPreferences: [DietaryPreference] = []
}
