//
//  UserModel.swift
//  MomCare
//
//  Created by Ritik Ranjan on 13/01/25.
//

import Foundation
import UIKit

enum PreExistingCondition: String, Codable, CaseIterable, Sendable {
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

enum MoodType: String, Codable, Sendable {
    case happy = "Happy"
    case sad = "Sad"
    case stressed = "Stressed"
    case angry = "Angry"
}

struct User: Codable, Sendable, Equatable {
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case emailAddress = "email_address"
        case password
        case countryCode = "country_code"
        case country
        case timezone
        case phoneNumber = "phone_number"

        case dateOfBirthTimestamp = "date_of_birth_timestamp"
        case height
        case prePregnancyWeight = "pre_pregnancy_weight"
        case currentWeight = "current_weight"
        case dueDateTimestamp = "due_date_timestamp"

        case preExistingConditions = "pre_existing_conditions"
        case foodIntolerances = "food_intolerances"
        case dietaryPreferences = "dietary_preferences"
    }

    // swiftlint:disable nesting

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
        var preExistingConditions: [PreExistingCondition] = .init()
        var foodIntolerances: [Intolerance] = .init()
        var dietaryPreferences: [DietaryPreference] = .init()
    }

    // swiftlint:enable nesting

    var firstName: String
    var lastName: String?

    var emailAddress: String
    var password: String?

    var countryCode: String = "91"
    var country: String = "India"

    var timezone: String?
    var phoneNumber: String

    var dateOfBirthTimestamp: TimeInterval?
    var height: Double?
    var prePregnancyWeight: Double?
    var currentWeight: Double?
    var dueDateTimestamp: TimeInterval?

    var preExistingConditions: [PreExistingCondition] = []
    var foodIntolerances: [Intolerance] = []
    var dietaryPreferences: [DietaryPreference] = []

    var plan: MyPlan = .init()
    var exercises: [Exercise] = []

    var fullName: String {
        let fullName = "\(firstName) \(lastName ?? "")"
        return fullName.trimmingCharacters(in: .whitespaces)
    }

    var pregancyData: (week: Int, day: Int, trimester: String)? {
        let dueDate = Date(timeIntervalSince1970: dueDateTimestamp ?? 0)
        return Utils.pregnancyWeekAndDay(dueDate: dueDate)
    }

    var medicalData: UserMedical? {
        guard let dateOfBirthTimestamp,
              let height,
              let prePregnancyWeight,
              let currentWeight else {
            return nil
        }

        let dob = Date(timeIntervalSince1970: dateOfBirthTimestamp)
        let dueDate = dueDateTimestamp != nil ? Date(timeIntervalSince1970: dueDateTimestamp!) : nil

        return UserMedical(
            dateOfBirth: dob,
            height: Double(height),
            prePregnancyWeight: prePregnancyWeight,
            currentWeight: currentWeight,
            dueDate: dueDate,
            preExistingConditions: preExistingConditions,
            foodIntolerances: foodIntolerances,
            dietaryPreferences: dietaryPreferences
        )
    }

}
