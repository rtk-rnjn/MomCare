//
//  UserModel.swift
//  MomCare
//
//  Created by Ritik Ranjan on 13/01/25.
//

import Foundation

enum Gender: String, Codable {
    case male
    case female
}

enum Country {
    case india
}

enum PreExistingCondition {
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

struct User {
    var firstName: String
    var lastName: String?

    var emailAddress: String
    var password: String

    var countryCode: String = "+91"
    var phoneNumber: String

    var dateOfBirth: Date
    var height: Double
    var prePregnancyWeight: Double
    var currentWeight: Double

    var gender: Gender = .female
    var country: Country = .india
    
    var dueDate: Date?
    var preExistingConditions: [PreExistingCondition] = []
    var foodIntolerances: [Intolerance] = []
}

class MomCareUser {
    private var userDiet: UserDiet?
    private var userExercise: UserExercise?

    static var shared: MomCareUser = MomCareUser()
    
    private init() {
        update()
    }
    
    private func update() {
        UserDiet.shared.updateFromDatabase()
        UserExercise.shared.updateFromDatabase()
    }
}
