//
//  UserHandler.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/02/25.
//

import Foundation
import OSLog

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

private let accessTokenValidDuration: TimeInterval = 5 * 60 - 10 // 5 minutes
private let logger: Logger = .init(subsystem: "com.MomCare.MomCareUser", category: "Network")

extension MomCareUser {

    private func serializeAndPost<T: Codable, R: Codable & Sendable>(
        _ object: T,
        endpoint: Endpoint,
        onFailureMessage: String
    ) async -> R? {
        guard let body = object.toData() else {
            logger.error("Failed to serialize data.")
            return nil
        }

        let response: R? = await NetworkManager.shared.post(url: endpoint.urlString, body: body)
        if response == nil {
            logger.error("\(onFailureMessage)")
        }
        return response
    }

    private func handleSuccessfulAuth(_ response: CreateResponse, email: String, password: String) {
        KeychainHelper.set(email, forKey: "emailAddress")
        KeychainHelper.set(password, forKey: "password")
        KeychainHelper.set(response.accessToken, forKey: "accessToken")
        logger.info("User authenticated successfully. Email: \(email, privacy: .private). Token: \(response.accessToken, privacy: .private(mask: .hash))")
        accessTokenExpiresAt = Date().addingTimeInterval(accessTokenValidDuration)
    }

    func createNewUser(_ user: User) async -> Bool {
        logger.info("Creating new user for email: \(user.emailAddress, privacy: .private)")

        guard let response: CreateResponse = await serializeAndPost(user,
            endpoint: .register,
            onFailureMessage: "User registration failed."
        ), response.success else {
            return false
        }

        handleSuccessfulAuth(response, email: user.emailAddress, password: user.password)

        self.user = user

        return true
    }

    func loginUser(email: String, password: String) async -> Bool {
        logger.info("Logging in user: \(email, privacy: .private)")

        let credentials = Credentials(emailAddress: email, password: password)
        guard let response: CreateResponse = await serializeAndPost(credentials,
            endpoint: .login,
            onFailureMessage: "Login failed for email: \(email)"
        ), response.success else {
            return false
        }

        handleSuccessfulAuth(response, email: email, password: password)
        return true
    }

    @objc func refreshToken() async -> Bool {
        logger.info("Refreshing access token")

        guard let email = KeychainHelper.get("emailAddress"),
              let password = KeychainHelper.get("password") else {
            logger.error("No stored credentials found for token refresh.")
            return false
        }

        let credentials = Credentials(emailAddress: email, password: password)
        guard let response: CreateResponse = await serializeAndPost(credentials,
            endpoint: Endpoint.refresh,
            onFailureMessage: "Token refresh failed."
        ), response.success else {
            return false
        }

        KeychainHelper.set(response.accessToken, forKey: "accessToken")
        logger.info("Access token refreshed successfully for email: \(email, privacy: .private). Token: \(response.accessToken, privacy: .private(mask: .hash))")
        accessTokenExpiresAt = Date().addingTimeInterval(accessTokenValidDuration)
        return true
    }

    func updateUser(_ updatedUser: User?) async -> Bool {
        guard let updatedUser else {
            logger.error("No user data to update.")
            return false
        }

        logger.info("Updating user for email: \(updatedUser.emailAddress, privacy: .private)")

        guard let response: UpdateResponse = await serializeAndPost(updatedUser,
            endpoint: .update,
            onFailureMessage: "User update failed."
        ), response.success else {
            return false
        }

        user = updatedUser
        return true
    }

    func isUserSignedUp() -> Bool {
        return Utils.get(fromKey: "isUserSignedUp", withDefaultValue: false) ?? false
    }

    func fetchUserFromDatabase(email: String, password: String, forceRefresh: Bool = false) async -> Bool {
        if let expiration = accessTokenExpiresAt, expiration <= Date() {
            logger.info("Access token expired. Attempting to refresh.")
            guard await refreshToken() else {
                logger.error("Failed to refresh token before fetching user.")
                return false
            }
        } else if accessTokenExpiresAt == nil {
            logger.info("Access token not set. Attempting to login.")
            guard await loginUser(email: email, password: password) else {
                logger.error("Failed to login before fetching user.")
                return false
            }
        }

        logger.info("Fetching user from DB for email: \(email, privacy: .private)")
        guard let user: User = await NetworkManager.shared.get(url: Endpoint.fetch.urlString) else {
            logger.error("Failed to fetch user from DB.")
            return false
        }

        self.user = user
        KeychainHelper.set(user.emailAddress, forKey: "emailAddress")
        KeychainHelper.set(user.password, forKey: "password")
        return true
    }

    @discardableResult
    func automaticFetchUserFromDatabase() async -> Bool {
        guard let email = KeychainHelper.get("emailAddress"),
              let password = KeychainHelper.get("password") else {
            logger.error("No stored credentials found for automatic fetch.")
            return false
        }

        if await fetchUserFromDatabase(email: email, password: password) {
            logger.info("User fetched successfully.")
            return true
        } else {
            logger.error("Failed to fetch user automatically.")
            return false
        }
    }

    func requestOTP() async -> Bool? {
        guard let emailAddress = KeychainHelper.get("emailAddress") else {
            return false
        }

        guard let data = EmailAddress(emailAddress: emailAddress).toData() else {
            return false
        }

        return await NetworkManager.shared.post(url: Endpoint.reqeustOTP.urlString, body: data)
    }

    func resendOTP() async -> Bool? {
        return await requestOTP()
    }

    func verifyOTP(otp: String) async -> Bool? {
        guard let emailAddress = KeychainHelper.get("emailAddress") else {
            return false
        }

        let verifyOTP = VerifyOTP(emailAddress: emailAddress, otp: otp)
        guard let data = verifyOTP.toData() else {
            return false
        }

        return await NetworkManager.shared.post(url: Endpoint.verifyOTP.urlString, body: data)
    }
}
