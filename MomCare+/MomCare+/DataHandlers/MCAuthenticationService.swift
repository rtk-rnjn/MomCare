import Combine
import Foundation
import SwiftUI

protocol TokenContaining: Sendable {
    nonisolated var accessToken: String { get }
    nonisolated var refreshToken: String { get }
    nonisolated var expiresAtTimestamp: TimeInterval { get }
}

enum LoginProvider {
    case apple
}

final class MCAuthenticationService: ObservableObject {
    // MARK: Lifecycle

    init() {
        if let userModelData: UserModel = Database.shared[.userModel] {
            userModel = userModelData
        }

        if let credentialsData: UserCredential = Database.shared[.credentials] {
            credentials = credentialsData
        }

        loadTokenPairIfNeeded()
    }

    // MARK: Internal

    nonisolated static var authorizationHeaders: [String: String]? {
        guard let accessToken = KeychainHelper.get(.accessToken), !accessToken.isEmpty else {
            return nil
        }

        return ["Authorization": "Bearer \(accessToken)"]
    }

    @Published var hasAccessToken: Bool = false

    var requiresRefresh: Bool {
        guard let expiresAtTimestamp = tokenPair?.expiresAtTimestamp else {
            return true
        }

        return expiresAtTimestamp <= Date.now.timeIntervalSince1970
    }

    @Published var tokenPair: (any TokenContaining & Codable)? {
        didSet {
            switch tokenPair {
            case let pair as TokenPair:
                Database.shared[.tokenPair] = pair

            case let response as RegistrationResponse:
                Database.shared[.tokenPair] = response

            default:
                break
            }
        }
    }

    @Published var credentials: UserCredential? {
        didSet {
            Database.shared[.credentials] = credentials
        }
    }

    @Published var userModel: UserModel? {
        didSet {
            Database.shared[.userModel] = userModel
        }
    }

    @discardableResult
    nonisolated func register(emailAddress: String, password: String) async throws -> NetworkResponse<RegistrationResponse> {
        let response: NetworkResponse<RegistrationResponse> = try await MCNetworkManager.shared.post(url: Endpoint.register.urlString, body: prepareCredentialsData(emailAddress: emailAddress, password: password))

        let success = handleSuccess(response, expectedStatusCode: 201)
        try await fetchCredentials()
        return success
    }

    @discardableResult
    nonisolated func login(emailAddress: String, password: String) async throws -> NetworkResponse<TokenPair> {
        let networkResponse: NetworkResponse<TokenPair> = try await MCNetworkManager.shared.post(url: Endpoint.login.urlString, body: prepareCredentialsData(emailAddress: emailAddress, password: password))

        _ = handleSuccess(networkResponse, expectedStatusCode: 200)

        KeychainHelper.set(password, forKey: .password)

        try await fetchCredentials()

        return networkResponse
    }

    nonisolated func refresh(refreshToken: String) async throws -> NetworkResponse<TokenPair> {
        let refreshTokenData = try RefreshToken(refreshToken: refreshToken).encodeUsingJSONEncoder()
        let response: NetworkResponse<TokenPair> = try await MCNetworkManager.shared.post(url: Endpoint.refresh.urlString, body: refreshTokenData)

        let success = handleSuccess(response, expectedStatusCode: 200)
        try await fetchCredentials()
        return success
    }

    @discardableResult
    nonisolated func refresh() async throws -> NetworkResponse<TokenPair>? {
        if let refreshToken = KeychainHelper.get(.refreshToken) {
            return try await refresh(refreshToken: refreshToken)
        }

        return nil
    }

    @discardableResult
    nonisolated func logout(refreshToken: String) async throws -> NetworkResponse<ServerMessage> {
        let refreshTokenData = try RefreshToken(refreshToken: refreshToken).encodeUsingJSONEncoder()
        let response: NetworkResponse<ServerMessage> = try await MCNetworkManager.shared.post(url: Endpoint.logout.urlString, body: refreshTokenData)

        await MainActor.run {
            dropCredentials()
            hasAccessToken = false
        }
        return response
    }

    @discardableResult
    func logout() async -> NetworkResponse<ServerMessage>? {
        if let refreshToken = KeychainHelper.get(.refreshToken) {
            _ = try? await logout(refreshToken: refreshToken)
        }

        dropCredentials()
        return nil
    }

    @discardableResult
    nonisolated func update(
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
        return try await MCNetworkManager.shared.patch(url: Endpoint.update.urlString, body: payloadData, headers: MCAuthenticationService.authorizationHeaders)
    }

    @discardableResult
    nonisolated func changeEmailAddress(newEmailAddress: String) async throws -> NetworkResponse<ServerMessage> {
        let payloadData = try ChangeEmailAddress(newEmailAddress: newEmailAddress).encodeUsingJSONEncoder()
        return try await MCNetworkManager.shared.patch(url: Endpoint.changeEmail.urlString, body: payloadData, headers: MCAuthenticationService.authorizationHeaders)
    }

    @discardableResult
    nonisolated func changePassword(currentPassword: String, newPassword: String) async throws -> NetworkResponse<ServerMessage> {
        let payloadData = try ChangePassword(currentPassword: currentPassword, newPassword: newPassword).encodeUsingJSONEncoder()
        return try await MCNetworkManager.shared.patch(url: Endpoint.changePassword.urlString, body: payloadData, headers: MCAuthenticationService.authorizationHeaders)
    }

    @discardableResult
    nonisolated func requestOTP(emailAddress: String) async throws -> NetworkResponse<ServerMessage> {
        let payloadData = try RequestOTP(emailAddress: emailAddress).encodeUsingJSONEncoder()
        return try await MCNetworkManager.shared.post(url: Endpoint.requestOTP.urlString, body: payloadData)
    }

    @discardableResult
    func requestOTP() async throws -> NetworkResponse<ServerMessage> {
        let credentials: UserCredential? = Database.shared[.credentials]
        return try await requestOTP(emailAddress: credentials?.emailAddress ?? "")
    }

    @discardableResult
    nonisolated func verifyOTP(emailAddress: String, otp: String) async throws -> NetworkResponse<ServerMessage> {
        let payloadData = try VerifyOTP(emailAddress: emailAddress, otp: otp).encodeUsingJSONEncoder()
        return try await MCNetworkManager.shared.post(url: Endpoint.verifyOTP.urlString, body: payloadData)
    }

    @discardableResult
    func verifyOTP(otp: String) async throws -> NetworkResponse<ServerMessage> {
        let credentials: UserCredential? = Database.shared[.credentials]
        return try await verifyOTP(emailAddress: credentials?.emailAddress ?? "", otp: otp)
    }

    @discardableResult
    nonisolated func delete() async throws -> NetworkResponse<Bool> {
        let networkResponse: NetworkResponse<Bool> = try await MCNetworkManager.shared.delete(url: Endpoint.delete.urlString, headers: MCAuthenticationService.authorizationHeaders)

        await MainActor.run {
            dropCredentials()
        }
        return networkResponse
    }

    nonisolated func appleLogin(idToken: String, existingEmailAddress: String? = nil) async throws -> NetworkResponse<TokenPair> {
        let payloadData = try ThirdPartyLogin(idToken: idToken, existingEmailAddress: existingEmailAddress).encodeUsingJSONEncoder()
        let response: NetworkResponse<TokenPair> = try await MCNetworkManager.shared.post(url: Endpoint.appleLogin.urlString, body: payloadData)

        let success = handleSuccess(response, expectedStatusCode: 200)
        try await fetchCredentials()
        return success
    }

    @discardableResult
    nonisolated func me() async throws -> NetworkResponse<UserModel> {
        let response: NetworkResponse<UserModel> = try await MCNetworkManager.shared.get(url: Endpoint.me.urlString, headers: MCAuthenticationService.authorizationHeaders)

        await MainActor.run {
            userModel = response.data
        }
        return response
    }

    @discardableResult
    nonisolated func fetchCredentials() async throws -> NetworkResponse<UserCredential> {
        let response: NetworkResponse<UserCredential> = try await MCNetworkManager.shared.get(url: Endpoint.credentials.urlString, headers: MCAuthenticationService.authorizationHeaders)

        await MainActor.run {
            credentials = response.data
        }
        return response
    }

    @discardableResult
    nonisolated func login(with provider: LoginProvider = .apple, token: String) async throws -> NetworkResponse<TokenPair> {
        switch provider {
        case .apple:
            try await loginWithApple(token: token)
        }
    }

    @discardableResult
    nonisolated func forgetPassword(emailAddress: String) async throws -> NetworkResponse<ServerMessage> {
        let payloadData = try ForgetPassword(emailAddress: emailAddress).encodeUsingJSONEncoder()
        return try await MCNetworkManager.shared.post(url: Endpoint.forgetPassword.urlString, body: payloadData)
    }

    @discardableResult
    nonisolated func resetPassword(emailAddress: String, otp: String, newPassword: String) async throws -> NetworkResponse<ServerMessage> {
        let payloadData = try ResetPassword(emailAddress: emailAddress, otp: otp, newPassword: newPassword).encodeUsingJSONEncoder()
        return try await MCNetworkManager.shared.post(url: Endpoint.resetPassword.urlString, body: payloadData)
    }

    // MARK: Private

    private func loadTokenPairIfNeeded() {
        if let pair: TokenPair = Database.shared[.tokenPair] {
            tokenPair = pair
        }

        if let response: RegistrationResponse = Database.shared[.tokenPair] {
            tokenPair = response
        }

        let accessToken = KeychainHelper.get(.accessToken) ?? tokenPair?.accessToken
        let expiresAtTimestamp = tokenPair?.expiresAtTimestamp ?? 0

        if let accessToken, !accessToken.isEmpty {
            hasAccessToken = expiresAtTimestamp > Date.now.timeIntervalSince1970
        } else {
            hasAccessToken = false
        }
    }

    nonisolated private func handleSuccess<T: TokenContaining>(_ response: NetworkResponse<T>, expectedStatusCode _: Int) -> NetworkResponse<T> {
        self.persistSession(accessToken: response.data.accessToken, refreshToken: response.data.refreshToken, expiresAtTimestamp: response.data.expiresAtTimestamp)

        DispatchQueue.main.async {
            self.tokenPair = response.data
        }
        return response
    }

    nonisolated private func persistSession(accessToken: String, refreshToken: String, expiresAtTimestamp: TimeInterval) {
        KeychainHelper.set(accessToken, forKey: .accessToken)
        KeychainHelper.set(refreshToken, forKey: .refreshToken)

        DispatchQueue.main.async {
            self.hasAccessToken = KeychainHelper.get(.accessToken)?.isEmpty == false && expiresAtTimestamp > Date.now.timeIntervalSince1970
        }
    }

    nonisolated private func prepareCredentialsData(emailAddress: String, password: String) -> Data? {
        try? LoginCredentials(emailAddress: emailAddress, password: password).encodeUsingJSONEncoder()
    }

    private func dropCredentials() {
        KeychainHelper.remove(.accessToken)
        KeychainHelper.remove(.refreshToken)

        hasAccessToken = false
        tokenPair = nil
        userModel = nil
        credentials = nil
        Database.shared.purge()
    }

    nonisolated private func loginWithApple(token: String) async throws -> NetworkResponse<TokenPair> {
        let payload = ThirdPartyLogin(idToken: token, existingEmailAddress: nil)
        let data = try payload.encodeUsingJSONEncoder()

        let response: NetworkResponse<TokenPair> = try await MCNetworkManager.shared.post(url: Endpoint.appleLogin.urlString, body: data)

        let success = handleSuccess(response, expectedStatusCode: 200)
        try await fetchCredentials()
        return success
    }
}
