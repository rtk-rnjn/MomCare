//
//  UserModel.swift
//  MomCare
//
//  Created by Ritik Ranjan on 13/01/25.
//

import Foundation

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

struct User: Codable {
    var id: UUID = .init()

    var firstName: String
    var lastName: String?

    var fullName: String {
        let fullName = "\(firstName) \(lastName ?? "")"
        return fullName.trimmingCharacters(in: .whitespaces)
    }

    var emailAddress: String
    var password: String

    var countryCode: String = "+91"
    var phoneNumber: String

    var medicalData: UserMedical?

    var mood: MoodType?
}

struct UserMedical: Codable {
    var dateOfBirth: Date
    var height: Double
    var prePregnancyWeight: Double
    var currentWeight: Double

    var country: Country = .india

    var dueDate: Date?

    var preExistingConditions: [PreExistingCondition] = []
    var foodIntolerances: [Intolerance] = []

    var dietaryPreferences: [DietaryPreference] = []
}

enum PickerOptions {
    case height
    case prePregnancyWeight
    case currentWeight
    case country
}
