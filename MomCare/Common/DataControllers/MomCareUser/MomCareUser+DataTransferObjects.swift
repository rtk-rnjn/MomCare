//
//  MomCareUser+DataTransferObjects.swift
//  MomCare
//
//  Created by RITIK RANJAN on 18/06/25.
//

import Foundation

/// Response returned after creating a new user in the backend.
///
/// Example: After signing up a new user, the API might return this DTO
/// containing success status, the inserted user ID, and an access token.
struct CreateResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case success
        case insertedId = "inserted_id"
        case accessToken = "access_token"
    }

    /// Indicates whether the creation was successful.
    let success: Bool

    /// The unique ID of the newly inserted user in the database.
    let insertedId: String

    /// JWT or API access token returned upon successful creation.
    let accessToken: String
}

/// Response returned after updating user information in the backend.
///
/// Example: When updating profile details, this DTO contains
/// the number of records matched and modified.
struct UpdateResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case success
        case modifiedCount = "modified_count"
        case matchedCount = "matched_count"
    }

    /// Indicates whether the update operation succeeded.
    let success: Bool

    /// Number of records actually modified.
    let modifiedCount: Int

    /// Number of records matched by the update query.
    let matchedCount: Int
}

/// Represents a user's login credentials.
///
/// Example: Used when sending login requests to the backend.
struct Credentials: Codable {
    enum CodingKeys: String, CodingKey {
        case emailAddress = "email_address"
        case password
    }

    /// The user's email address used for authentication.
    let emailAddress: String

    /// The user's password.
    let password: String
}

/// Represents only the email address of a user.
///
/// Example: Used when requesting OTPs or password reset links.
struct EmailAddress: Codable {
    enum CodingKeys: String, CodingKey {
        case emailAddress = "email_address"
    }

    /// The user's email address.
    let emailAddress: String
}

/// Represents the verification of an OTP (One-Time Password) for a user.
///
/// Example: Used when validating an OTP sent to the user's email.
struct VerifyOTP: Codable {
    enum CodingKeys: String, CodingKey {
        case emailAddress = "email_address"
        case otp
    }

    /// The user's email address where the OTP was sent.
    let emailAddress: String

    /// The OTP provided by the user for verification.
    let otp: String
}
