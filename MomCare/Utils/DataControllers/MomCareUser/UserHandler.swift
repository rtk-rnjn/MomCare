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

enum AuthenticationEndpoints {
    static let base = "/auth"

    static func registerUser() -> String { "\(base)/register" }
    static func loginUser() -> String { "\(base)/login" }
    static func refreshToken() -> String { "\(base)/refresh" }
    static func fetchUser() -> String { "\(base)/fetch" }
}

private let accessTokenValidDuration: TimeInterval = 5 * 60 - 10 // 5 minutes
private let logger: Logger = .init(subsystem: "com.MomCare.MomCareUser", category: "Network")

extension MomCareUser {

    private func serializeAndPost<T: Codable, R: Codable>(
        _ object: T,
        endpoint: String,
        onFailureMessage: String
    ) async -> R? {
        guard let body = object.toData() else {
            logger.error("Failed to serialize data.")
            return nil
        }

        let response: R? = await NetworkManager.shared.post(url: endpoint, body: body)
        if response == nil {
            logger.error("\(onFailureMessage)")
        }
        return response
    }

    private func handleSuccessfulAuth(_ response: CreateResponse, email: String, password: String) {
        KeychainHelper.set(email, forKey: "emailAddress")
        KeychainHelper.set(password, forKey: "password")
        KeychainHelper.set(response.accessToken, forKey: "accessToken")
        accessTokenExpiresAt = Date().addingTimeInterval(accessTokenValidDuration)
    }

    func createNewUser(_ user: User) async -> Bool {
        logger.info("Creating new user for email: \(user.emailAddress, privacy: .private)")

        guard let response: CreateResponse = await serializeAndPost(user,
            endpoint: AuthenticationEndpoints.registerUser(),
            onFailureMessage: "User registration failed."
        ), response.success else {
            return false
        }

        handleSuccessfulAuth(response, email: user.emailAddress, password: user.password)
        return true
    }

    func loginUser(email: String, password: String) async -> Bool {
        logger.info("Logging in user: \(email, privacy: .private)")

        let credentials = Credentials(emailAddress: email, password: password)
        guard let response: CreateResponse = await serializeAndPost(credentials,
            endpoint: AuthenticationEndpoints.loginUser(),
            onFailureMessage: "Login failed for email: \(email)"
        ), response.success else {
            return false
        }

        handleSuccessfulAuth(response, email: email, password: password)
        Utils.save(forKey: "isUserSignedUp", withValue: true)
        return true
    }

    func refreshToken() async -> Bool {
        logger.info("Refreshing access token")

        guard let email = KeychainHelper.get("emailAddress"),
              let password = KeychainHelper.get("password") else {
            logger.error("No stored credentials found for token refresh.")
            return false
        }

        let credentials = Credentials(emailAddress: email, password: password)
        guard let response: CreateResponse = await serializeAndPost(credentials,
            endpoint: AuthenticationEndpoints.refreshToken(),
            onFailureMessage: "Token refresh failed."
        ), response.success else {
            return false
        }

        KeychainHelper.set(response.accessToken, forKey: "accessToken")
        accessTokenExpiresAt = Date().addingTimeInterval(accessTokenValidDuration)
        return true
    }

    func isUserSignedUp() -> Bool {
        Utils.get(fromKey: "isUserSignedUp", withDefaultValue: false) ?? false
    }

    func fetchUserFromDatabase(with email: String, and password: String) async -> Bool {
        if let expiration = accessTokenExpiresAt, expiration <= Date() {
            logger.info("Access token expired. Attempting to refresh.")
            guard await refreshToken() else {
                logger.error("Failed to refresh token before fetching user.")
                return false
            }
        }

        logger.info("Fetching user from DB for email: \(email, privacy: .private)")
        let credentials = Credentials(emailAddress: email, password: password)
        guard let body = credentials.toData() else {
            logger.error("Failed to serialize credentials.")
            return false
        }

        guard let user: User = await NetworkManager.shared.post(url: AuthenticationEndpoints.fetchUser(), body: body) else {
            logger.error("Failed to fetch user from DB.")
            return false
        }

        self.user = user
        KeychainHelper.set(user.emailAddress, forKey: "emailAddress")
        KeychainHelper.set(user.password, forKey: "password")
        return true
    }
}
