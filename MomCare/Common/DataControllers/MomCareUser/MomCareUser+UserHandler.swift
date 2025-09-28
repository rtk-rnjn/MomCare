//
//  MomCareUser+UserHandler.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/02/25.
//

import Foundation
import OSLog

private let accessTokenValidDuration: TimeInterval = 5 * 60 - 10 // 5 minutes minus 10 seconds buffer
private let logger: Logger = .init(subsystem: "com.MomCare.MomCareUser", category: "Network")

extension MomCareUser {

    /// Serializes a Codable object to Data and performs a POST request to the specified endpoint.
    ///
    /// - Parameters:
    ///   - object: Codable object to serialize and send.
    ///   - endpoint: API endpoint to send the request.
    ///   - onFailureMessage: Message to log if the network request fails.
    /// - Returns: Decoded response object of type R, or nil if failed.
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

    /// Handles successful authentication by storing credentials in Keychain and setting the access token expiration.
    ///
    /// - Parameters:
    ///   - response: `CreateResponse` returned from the backend.
    ///   - email: User's email.
    ///   - password: User's password.
    private func handleSuccessfulAuth(_ response: CreateResponse, email: String, password: String) {
        KeychainHelper.set(email, forKey: "emailAddress")
        KeychainHelper.set(password, forKey: "password")
        KeychainHelper.set(response.accessToken, forKey: "accessToken")

        logger.info(
            "User authenticated successfully. Email: \(email, privacy: .private)."
        )

        accessTokenExpiresAt = Date().addingTimeInterval(accessTokenValidDuration)
    }

    /// Creates a new user by sending a registration request to the backend.
    ///
    /// - Parameter user: User object containing registration details.
    /// - Returns: True if creation succeeds, false otherwise.
    func createNewUser(_ user: User) async -> Bool {
        logger.info("Creating new user for email: \(user.emailAddress, privacy: .private)")

        guard let response: CreateResponse = await serializeAndPost(
            user,
            endpoint: .register,
            onFailureMessage: "User registration failed."
        ), response.success else {
            return false
        }

        handleSuccessfulAuth(response, email: user.emailAddress, password: user.password)
        self.user = user
        return true
    }

    /// Logs in an existing user.
    ///
    /// - Parameters:
    ///   - email: User's email.
    ///   - password: User's password.
    /// - Returns: True if login succeeds, false otherwise.
    func loginUser(email: String, password: String) async -> Bool {
        logger.info("Logging in user: \(email, privacy: .private)")

        let credentials = Credentials(emailAddress: email, password: password)
        guard let response: CreateResponse = await serializeAndPost(
            credentials,
            endpoint: .login,
            onFailureMessage: "Login failed for email: \(email)"
        ), response.success else {
            return false
        }

        handleSuccessfulAuth(response, email: email, password: password)
        return true
    }

    /// Refreshes the user's access token using stored credentials.
    ///
    /// - Returns: True if refresh succeeds, false otherwise.
    @objc func refreshToken() async -> Bool {
        logger.debug("Refreshing access token")

        guard let email = KeychainHelper.get("emailAddress"),
              let password = KeychainHelper.get("password") else {
            logger.error("No stored credentials found for token refresh.")
            return false
        }

        let credentials = Credentials(emailAddress: email, password: password)
        guard let response: CreateResponse = await serializeAndPost(
            credentials,
            endpoint: Endpoint.refresh,
            onFailureMessage: "Token refresh failed."
        ), response.success else {
            return false
        }

        KeychainHelper.set(response.accessToken, forKey: "accessToken")
        logger.info("Access token refreshed successfully for email: \(email, privacy: .private).")
        accessTokenExpiresAt = Date().addingTimeInterval(accessTokenValidDuration)
        return true
    }

    /// Updates the current user in the backend.
    ///
    /// - Parameter updatedUser: User object with updated data.
    /// - Returns: True if update succeeds, false otherwise.
    func updateUser(_ updatedUser: User?) async -> Bool {
        guard let updatedUser else {
            logger.error("No user data to update.")
            return false
        }

        logger.info("Updating user for email: \(updatedUser.emailAddress, privacy: .private)")

        guard let response: UpdateResponse = await serializeAndPost(
            updatedUser,
            endpoint: .update,
            onFailureMessage: "User update failed."
        ), response.success else {
            return false
        }

        user = updatedUser
        return true
    }

    /// Updates the user's medical data in the backend.
    ///
    /// - Parameter medicalData: UserMedical object containing updated medical information.
    /// - Returns: True if update succeeds, false otherwise.
    func updateUserMedical(_ medicalData: UserMedical) async -> Bool {
        guard let response: UpdateResponse = await serializeAndPost(
            medicalData,
            endpoint: .updateMedicalData,
            onFailureMessage: "User medical data update failed."
        ), response.success else {
            return false
        }

        user?.medicalData = medicalData
        return true
    }

    /// Checks if the user is signed up according to UserDefaults.
    func isUserSignedUp() -> Bool {
        return Utils.get(fromKey: "isUserSignedUp", withDefaultValue: false) ?? false
    }

    /// Fetches user from the backend database, handling token refresh or login if needed.
    ///
    /// - Parameters:
    ///   - email: User's email.
    ///   - password: User's password.
    ///   - forceRefresh: Whether to force refresh the user data.
    /// - Returns: True if fetching succeeds, false otherwise.
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

    /// Attempts to automatically fetch the user using stored credentials.
    ///
    /// - Returns: True if fetching succeeds, false otherwise.
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

    /// Requests an OTP for the stored email address.
    func requestOTP() async -> Bool? {
        guard let emailAddress = KeychainHelper.get("emailAddress") else {
            return false
        }

        guard let data = EmailAddress(emailAddress: emailAddress).toData() else {
            return false
        }

        return await NetworkManager.shared.post(url: Endpoint.reqeustOTP.urlString, body: data)
    }

    /// Resends the OTP for the stored email address.
    func resendOTP() async -> Bool? {
        return await requestOTP()
    }

    /// Verifies the provided OTP for the stored email address.
    ///
    /// - Parameter otp: One-Time Password provided by the user.
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
