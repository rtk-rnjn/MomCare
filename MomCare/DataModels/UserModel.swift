//
//  UserModel.swift
//  MomCare
//
//  Created by Ritik Ranjan on 13/01/25.
//

import Foundation
import UIKit

enum Country: String, Codable {
    case india
}

enum PreExistingCondition: Codable {
    case diabetes
    case hypertension
    case pcos
    case anemia
    case asthma
    case heartDisease
    case kidneyDisease
}

enum Intolerance: String, Codable {
    case gluten
    case lactose
    case egg
    case seafood
    case soy
    case dairy
    case wheat
}

enum DietaryPreference: Codable {
    case vegetarian
    case nonVegetarian
    case vegan
    case pescetarian
    case flexitarian
    case glutenFree
    case ketogenic
    case highProtein
    case dairyFree
}

public enum MoodType: String, Codable {
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

struct User: Codable {
    var id: UUID = .init()
    var firstName: String
    var lastName: String?
    var emailAddress: String
    var password: String
    var countryCode: String = "+91"
    var country: Country = .india
    var phoneNumber: String
    var medicalData: UserMedical?
    var mood: MoodType?
    var plan: MyPlan?
    var exercises: [Exercise] = []
    var history: [History] = []

    var fullName: String {
        let fullName = "\(firstName) \(lastName ?? "")"
        return fullName.trimmingCharacters(in: .whitespaces)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case emailAddress = "email_address"
        case password
        case countryCode = "country_code"
        case phoneNumber = "phone_number"
        case medicalData = "medical_data"
        case mood
        case plan
        case exercises
        case history
    }
}

struct History: Codable {
    var date: Date = .init()
    var plan: MyPlan?
    var exercises: [Exercise] = []

    enum CodingKeys: String, CodingKey {
        case date
        case plan
        case exercises
    }
}

struct UserMedical: Codable {
    var dateOfBirth: Date
    var height: Double
    var prePregnancyWeight: Double
    var currentWeight: Double
    var dueDate: Date?
    var preExistingConditions: [PreExistingCondition] = []
    var foodIntolerances: [Intolerance] = []
    var dietaryPreferences: [DietaryPreference] = []

    enum CodingKeys: String, CodingKey {
        case dateOfBirth = "date_of_birth"
        case height
        case prePregnancyWeight = "pre_pregnancy_weight"
        case currentWeight = "current_weight"
        case country
        case dueDate = "due_date"
        case preExistingConditions = "pre_existing_conditions"
        case foodIntolerances = "food_intolerances"
        case dietaryPreferences = "dietary_preferences"
    }
}

