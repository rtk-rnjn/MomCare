//
//  UserModel.swift
//  MomCare
//
//  Created by Ritik Ranjan on 13/01/25.
//

import Foundation
import UIKit

enum Country: String, Codable {
    case india = "India"
}

public enum PreExistingCondition: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case diabetes = "Diabetes"
    case hypertension = "Hypertension"
    case pcos = "PCOS"
    case anemia = "Anemia"
    case asthma = "Asthma"
    case heartDisease = "Heart Disease"
    case kidneyDisease = "Kidney Disease"
}

public enum Intolerance: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case gluten = "Gluten"
    case lactose = "Lactose"
    case egg = "Egg"
    case seafood = "Seafood"
    case soy = "Soy"
    case dairy = "Dairy"
    case wheat = "Wheat"
}

public enum DietaryPreference: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case vegetarian = "Vegetarian"
    case nonVegetarian = "Non-Vegetarian"
    case vegan = "Vegan"
    case pescetarian = "Pescetarian"
    case flexitarian = "Flexitarian"
    case glutenFree = "Gluten-Free"
    case ketogenic = "Ketogenic"
    case highProtein = "High Protein"
    case dairyFree = "Dairy-Free"
}

public enum MoodType: String, Codable, Sendable {
   case happy = "Happy"
   case sad = "Sad"
   case stressed = "Stressed"
   case angry = "Angry"
}

struct Mood: Codable {
    var imageName: String
    var type: MoodType

    var image: UIImage? {
        return UIImage(named: imageName)
    }
}

struct User: Codable, Sendable, Equatable {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case emailAddress = "email_address"
        case password
        case countryCode = "country_code"
        case country
        case phoneNumber = "phone_number"
        case medicalData = "medical_data"
        case mood
        case plan
        case exercises
        case history
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var id: String = UUID().uuidString
    var firstName: String
    var lastName: String?
    var emailAddress: String
    var password: String
    var countryCode: String = "91"
    var country: Country = .india
    var phoneNumber: String
    var medicalData: UserMedical?
    var mood: MoodType?
    var plan: MyPlan?
    var exercises: [Exercise] = []
    var history: [History] = []
    var createdAt: Date = .init()
    var updatedAt: Date?

    var fullName: String {
        let fullName = "\(firstName) \(lastName ?? "")"
        return fullName.trimmingCharacters(in: .whitespaces)
    }
}

struct History: Codable, Sendable, Equatable {
    enum CodingKeys: String, CodingKey {
        case date
        case plan
        case exercises
    }

    var date: Date = .init()
    var plan: MyPlan?
    var exercises: [Exercise] = []

    static func == (lhs: History, rhs: History) -> Bool {
        let date = lhs.date == rhs.date
        let plan = lhs.plan == rhs.plan
        let exercises = lhs.exercises == rhs.exercises

        return date && plan && exercises
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

    static func == (lhs: UserMedical, rhs: UserMedical) -> Bool {
        let dateOfBirth = lhs.dateOfBirth == rhs.dateOfBirth
        let height = lhs.height == rhs.height
        let prePregnancyWeight = lhs.prePregnancyWeight == rhs.prePregnancyWeight
        let currentWeight = lhs.currentWeight == rhs.currentWeight
        let dueDate = lhs.dueDate == rhs.dueDate
        let preExistingConditions = lhs.preExistingConditions == rhs.preExistingConditions
        let foodIntolerances = lhs.foodIntolerances == rhs.foodIntolerances
        let dietaryPreferences = lhs.dietaryPreferences == rhs.dietaryPreferences

        return dateOfBirth && height && prePregnancyWeight && currentWeight && dueDate && preExistingConditions && foodIntolerances && dietaryPreferences
    }
}
