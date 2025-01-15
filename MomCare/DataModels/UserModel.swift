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
    // MARK: TODO FIX THIS SHIT  // swiftlint:disable:this todo
}

class MomCareUser {
    static var shared: MomCareUser = MomCareUser()
}
