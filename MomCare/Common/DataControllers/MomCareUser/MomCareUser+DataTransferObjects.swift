//
//  MomCareUser+DataTransferObjects.swift
//  MomCare
//
//  Created by RITIK RANJAN on 18/06/25.
//

import Foundation

struct CreateResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case success
        case insertedId = "inserted_id"
        case accessToken = "access_token"
    }

    let success: Bool
    let insertedId: String
    let accessToken: String
}

struct UpdateResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case success
        case modifiedCount = "modified_count"
        case matchedCount = "matched_count"
    }

    let success: Bool
    let modifiedCount: Int
    let matchedCount: Int
}

struct Credentials: Codable {
    enum CodingKeys: String, CodingKey {
        case emailAddress = "email_address"
        case password
    }

    let emailAddress: String
    let password: String
}

struct EmailAddress: Codable {
    enum CodingKeys: String, CodingKey {
        case emailAddress = "email_address"
    }

    let emailAddress: String
}

struct VerifyOTP: Codable {
    enum CodingKeys: String, CodingKey {
        case emailAddress = "email_address"
        case otp
    }

    let emailAddress: String
    let otp: String
}
