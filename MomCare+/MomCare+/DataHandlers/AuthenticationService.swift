import Combine
import Foundation
import SwiftUI

protocol TokenContaining {
    var accessToken: String { get }
    var refreshToken: String { get }
    var expiresAtTimestamp: TimeInterval { get }
}

enum LoginProvider {
    case apple
}

final class AuthenticationService: ObservableObject {

    // MARK: Lifecycle

    init() {
        if let userModelData: UserModel = database[.userModel] {
            userModel = userModelData
        }

        if let credentialsData: UserCredential = database[.credentials] {
            credentials = credentialsData
        }

        if let expiresAtTimestamp: TimeInterval = database[.accessTokenExpiresAtTimestamp], let accessToken: String = KeychainHelper.get(.accessToken) {
            let now = Date.now.timeIntervalSince1970
            hasAccessToken = !accessToken.isEmpty && expiresAtTimestamp > now
        }
    }

    // MARK: Internal

    static var authorizationHeaders: [String: String]? {
        guard let accessToken = KeychainHelper.get(.accessToken), !accessToken.isEmpty else {
            return nil
        }
        return ["Authorization": "Bearer \(accessToken)"]
    }

    @Published var hasAccessToken: Bool = false
    @Published var credentials: UserCredential?

    @Published var userModel: UserModel? {
        didSet {
            database[.userModel] = userModel
        }
    }

    @discardableResult
    func register(emailAddress: String, password: String) async throws -> NetworkResponse<RegistrationResponse> {
        DebugLogger.shared.log("Registering user: \(emailAddress)", level: .info, category: .network)
        let response: NetworkResponse<RegistrationResponse> = try await NetworkManager.shared.post(url: Endpoint.register.urlString, body: prepareCredentialsData(emailAddress: emailAddress, password: password))

        DebugLogger.shared.log("Registration response: status=\(response.statusCode), error=\(response.errorMessage ?? "none")", level: response.success ? .info : .error, category: .network)
        return handleSuccess(response, expectedStatusCode: 201)
    }

    @discardableResult
    func login(emailAddress: String, password: String) async throws -> NetworkResponse<TokenPair> {
        DebugLogger.shared.log("Logging in user: \(emailAddress)", level: .info, category: .network)
        let networkResponse: NetworkResponse<TokenPair> = try await NetworkManager.shared.post(url: Endpoint.login.urlString, body: prepareCredentialsData(emailAddress: emailAddress, password: password))

        let response = handleSuccess(networkResponse, expectedStatusCode: 200)
        if response.statusCode == 200 {
            DebugLogger.shared.log("Login successful, fetching user profile", level: .debug, category: .network)

        } else {
            DebugLogger.shared.log("Login failed: status=\(response.statusCode), error=\(response.errorMessage ?? "none")", level: .error, category: .network)
        }

        KeychainHelper.set(password, forKey: .password)
        return networkResponse
    }

    func refresh(refreshToken: String) async throws -> NetworkResponse<TokenPair> {
        DebugLogger.shared.log("Refreshing access token", level: .debug, category: .network)
        let refreshTokenData = RefreshToken(refreshToken: refreshToken).encodeUsingJSONEncoder()
        let response: NetworkResponse<TokenPair> = try await NetworkManager.shared.post(url: Endpoint.refresh.urlString, body: refreshTokenData)

        DebugLogger.shared.log("Token refresh response: status=\(response.statusCode)", level: response.success ? .debug : .warning, category: .network)
        return handleSuccess(response, expectedStatusCode: 200)
    }

    @discardableResult
    func refresh() async throws -> NetworkResponse<TokenPair>? {
        if let refreshToken = KeychainHelper.get(.refreshToken) {
            return try await refresh(refreshToken: refreshToken)
        } else {
            DebugLogger.shared.log("Token refresh skipped: no refresh token stored", level: .warning, category: .network)
        }

        return nil
    }

    @discardableResult
    func logout(refreshToken: String) async throws -> NetworkResponse<ServerMessage> {
        DebugLogger.shared.log("Logging out user", level: .info, category: .network)
        let refreshTokenData = RefreshToken(refreshToken: refreshToken).encodeUsingJSONEncoder()
        let response: NetworkResponse<ServerMessage> = try await NetworkManager.shared.post(url: Endpoint.logout.urlString, body: refreshTokenData)

        dropCredentials()
        hasAccessToken = false

        DebugLogger.shared.log("Logout complete: status=\(response.statusCode)", level: .info, category: .network)
        return response
    }

    @discardableResult
    func logout() async -> NetworkResponse<ServerMessage>? {
        DebugLogger.shared.log("Logging out (no token)", level: .info, category: .network)
        if let refreshToken = KeychainHelper.get(.refreshToken) {
            _ = try? await logout(refreshToken: refreshToken)
        }
        dropCredentials()
        hasAccessToken = false
        userModel = nil

        return nil
    }

    @discardableResult
    func update(
        firstName: FieldType<String> = .unset,
        lastName: FieldType<String> = .unset,
        phoneNumber: FieldType<String> = .unset,
        dateOfBirthTimestamp: FieldType<TimeInterval> = .unset,

        height: FieldType<Int> = .unset,
        prePregnancyWeight: FieldType<Int> = .unset,
        currentWeight: FieldType<Int> = .unset,

        dueDateTimestamp: FieldType<TimeInterval> = .unset,

        foodIntolerances: FieldType<[String]> = .unset,
        dietaryPreferences: FieldType<[String]> = .unset
    ) async throws -> NetworkResponse<ServerMessage> {
        var payload = [String: any Codable]()

        func insertIfSet(_ field: FieldType<some Codable>, key: String) {
            switch field {
            case let .value(value):
                payload[key] = value
            case .null:
                payload[key] = nil
            case .unset:
                break
            }
        }

        insertIfSet(firstName, key: "first_name")
        insertIfSet(lastName, key: "last_name")
        insertIfSet(phoneNumber, key: "phone_number")
        insertIfSet(dateOfBirthTimestamp, key: "date_of_birth_timestamp")
        insertIfSet(height, key: "height")
        insertIfSet(prePregnancyWeight, key: "pre_pregnancy_weight")
        insertIfSet(currentWeight, key: "current_weight")
        insertIfSet(dueDateTimestamp, key: "due_date_timestamp")
        insertIfSet(foodIntolerances, key: "food_intolerances")
        insertIfSet(dietaryPreferences, key: "dietary_preferences")

        let payloadData = try JSONSerialization.data(withJSONObject: payload, options: [])
        return try await NetworkManager.shared.patch(url: Endpoint.update.urlString, body: payloadData, headers: AuthenticationService.authorizationHeaders)
    }

    @discardableResult
    func changeEmailAddress(newEmailAddress: String) async throws -> NetworkResponse<ServerMessage> {
        DebugLogger.shared.log("Changing email address", level: .info, category: .network)
        let payloadData = ChangeEmailAddress(newEmailAddress: newEmailAddress).encodeUsingJSONEncoder()
        let response: NetworkResponse<ServerMessage> = try await NetworkManager.shared.patch(url: Endpoint.changeEmail.urlString, body: payloadData, headers: AuthenticationService.authorizationHeaders)

        if response.errorMessage == nil, response.statusCode == 200 {
            DebugLogger.shared.log("Email address changed successfully", level: .info, category: .network)
        } else {
            DebugLogger.shared.log("Email change failed: status=\(response.statusCode), error=\(response.errorMessage ?? "none")", level: .error, category: .network)
        }

        return response
    }

    @discardableResult
    func changePassword(currentPassword: String, newPassword: String) async throws -> NetworkResponse<ServerMessage> {
        DebugLogger.shared.log("Changing password", level: .info, category: .network)
        let payloadData = ChangePassword(currentPassword: currentPassword, newPassword: newPassword).encodeUsingJSONEncoder()
        let response: NetworkResponse<ServerMessage> = try await NetworkManager.shared.patch(url: Endpoint.changePassword.urlString, body: payloadData, headers: AuthenticationService.authorizationHeaders)

        if response.errorMessage == nil, response.statusCode == 200 {
            DebugLogger.shared.log("Password changed successfully", level: .info, category: .network)
            KeychainHelper.set(newPassword, forKey: .password)
        } else {
            DebugLogger.shared.log("Password change failed: status=\(response.statusCode)", level: .error, category: .network)
        }

        return response
    }

    @discardableResult
    func requestOTP(emailAddress: String) async throws -> NetworkResponse<ServerMessage> {
        DebugLogger.shared.log("Requesting OTP for \(emailAddress)", level: .info, category: .network)
        let payloadData = RequestOTP(emailAddress: emailAddress).encodeUsingJSONEncoder()
        return try await NetworkManager.shared.post(url: Endpoint.requestOTP.urlString, body: payloadData)
    }

    @discardableResult
    func requestOTP() async throws -> NetworkResponse<ServerMessage> {
        let credentials: UserCredential? = database[.credentials]
        return try await requestOTP(emailAddress: credentials?.emailAddress ?? "")
    }

    @discardableResult
    func verifyOTP(emailAddress: String, otp: String) async throws -> NetworkResponse<ServerMessage> {
        DebugLogger.shared.log("Verifying OTP for \(emailAddress)", level: .info, category: .network)
        let payloadData = VerifyOTP(emailAddress: emailAddress, otp: otp).encodeUsingJSONEncoder()
        return try await NetworkManager.shared.post(url: Endpoint.verifyOTP.urlString, body: payloadData)
    }

    @discardableResult
    func verifyOTP(otp: String) async throws -> NetworkResponse<ServerMessage> {
        let credentials: UserCredential? = database[.credentials]
        return try await verifyOTP(emailAddress: credentials?.emailAddress ?? "", otp: otp)
    }

    @discardableResult
    func delete() async throws -> NetworkResponse<Bool> {
        DebugLogger.shared.log("Deleting account", level: .warning, category: .network)
        let networkResponse: NetworkResponse<Bool> = try await NetworkManager.shared.delete(url: Endpoint.delete.urlString, headers: AuthenticationService.authorizationHeaders)
        if networkResponse.success {
            DebugLogger.shared.log("Account deleted successfully", level: .info, category: .network)
            dropCredentials()
        } else {
            DebugLogger.shared.log("Account deletion failed: status=\(networkResponse.statusCode)", level: .error, category: .network)
        }
        return networkResponse
    }

    func appleLogin(idToken: String, existingEmailAddress: String? = nil) async throws -> NetworkResponse<TokenPair> {
        DebugLogger.shared.log("Attempting Apple login", level: .info, category: .network)
        let payloadData = ThirdPartyLogin(idToken: idToken, existingEmailAddress: existingEmailAddress).encodeUsingJSONEncoder()
        let response: NetworkResponse<TokenPair> = try await NetworkManager.shared.post(url: Endpoint.appleLogin.urlString, body: payloadData)

        return handleSuccess(response, expectedStatusCode: 200)
    }

    @discardableResult
    func me() async throws -> NetworkResponse<UserModel> {
        DebugLogger.shared.log("Fetching current user profile", level: .debug, category: .network)
        let response: NetworkResponse<UserModel> = try await NetworkManager.shared.get(url: Endpoint.me.urlString, headers: AuthenticationService.authorizationHeaders)

        if response.errorMessage == nil, response.statusCode == 200, let userModel = response.data {
            DebugLogger.shared.log("User profile fetched: \(userModel._id)", level: .debug, category: .data)
            await MainActor.run {
                self.userModel = userModel
            }
            database[.userModel] = userModel
        } else {
            DebugLogger.shared.log("Failed to fetch user profile: status=\(response.statusCode)", level: .error, category: .network)
        }

        return response
    }

    @discardableResult
    func fetchCredentials() async throws -> NetworkResponse<UserCredential> {
        DebugLogger.shared.log("Fetching user credentials", level: .debug, category: .network)
        let response: NetworkResponse<UserCredential> = try await NetworkManager.shared.get(url: Endpoint.credentials.urlString, headers: AuthenticationService.authorizationHeaders)
        if response.errorMessage == nil, response.statusCode == 200, let credentials = response.data {
            DebugLogger.shared.log("User credentials fetched successfully", level: .debug, category: .data)
            await MainActor.run {
                self.credentials = credentials
            }
            database[.credentials] = credentials
        } else {
            DebugLogger.shared.log("Failed to fetch credentials: status=\(response.statusCode)", level: .error, category: .network)
        }
        return response
    }

    @discardableResult
    func login(with provider: LoginProvider = .apple, token: String) async throws -> NetworkResponse<TokenPair> {
        switch provider {
        case .apple:
            return try await loginWithApple(token: token)
        }
    }

    // MARK: Private

    private let database: Database = .init()

    private func handleSuccess<T: TokenContaining>(_ response: NetworkResponse<T>, expectedStatusCode: Int) -> NetworkResponse<T> {
        let success = response.errorMessage == nil && response.statusCode == expectedStatusCode && response.data != nil
        guard success, let data = response.data else {
            DebugLogger.shared.log("Auth session persistence skipped: status=\(response.statusCode), error=\(response.errorMessage ?? "none")", level: .warning, category: .network)
            hasAccessToken = false
            return response
        }

        DebugLogger.shared.log("Persisting auth session for current user", level: .debug, category: .network)
        persistSession(accessToken: data.accessToken, refreshToken: data.refreshToken, expiresAtTimestamp: data.expiresAtTimestamp)

        return response
    }

    private func persistSession(accessToken: String, refreshToken: String, expiresAtTimestamp: TimeInterval) {
        KeychainHelper.set(accessToken, forKey: .accessToken)
        KeychainHelper.set(refreshToken, forKey: .refreshToken)

        database[.accessTokenExpiresAtTimestamp] = expiresAtTimestamp

        hasAccessToken = KeychainHelper.get(.accessToken)?.isEmpty == false && expiresAtTimestamp > Date.now.timeIntervalSince1970
    }

    private func prepareCredentialsData(emailAddress: String, password: String) -> Data? {
        let credentialsModel = LoginCredentials(emailAddress: emailAddress, password: password)

        return credentialsModel.encodeUsingJSONEncoder()
    }

    private func dropCredentials() {
        KeychainHelper.remove(.accessToken)
        KeychainHelper.remove(.refreshToken)

        database.delete(.accessTokenExpiresAtTimestamp)
        database.delete(.credentials)
        database.delete(.userModel)

        userModel = nil
    }

    private func loginWithApple(token: String) async throws -> NetworkResponse<TokenPair> {
        let payload = ThirdPartyLogin(idToken: token, existingEmailAddress: nil)
        guard let data = payload.encodeUsingJSONEncoder() else {
            fatalError()
        }

        let response: NetworkResponse<TokenPair> = try await NetworkManager.shared.post(url: Endpoint.appleLogin.urlString, body: data)
        return handleSuccess(response, expectedStatusCode: 200)
    }
}
