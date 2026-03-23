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
        if let userModelData: UserModel = Database.shared[.userModel] {
            userModel = userModelData
        }

        if let credentialsData: UserCredential = Database.shared[.credentials] {
            credentials = credentialsData
        }

        loadTokenPairIfNeeded()
    }

    // MARK: Internal

    static var authorizationHeaders: [String: String]? {
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
    func register(emailAddress: String, password: String) async throws -> NetworkResponse<RegistrationResponse> {
        let response: NetworkResponse<RegistrationResponse> = try await NetworkManager.shared.post(url: Endpoint.register.urlString, body: prepareCredentialsData(emailAddress: emailAddress, password: password))

        try await fetchCredentials()
        return handleSuccess(response, expectedStatusCode: 201)
    }

    @discardableResult
    func login(emailAddress: String, password: String) async throws -> NetworkResponse<TokenPair> {
        let networkResponse: NetworkResponse<TokenPair> = try await NetworkManager.shared.post(url: Endpoint.login.urlString, body: prepareCredentialsData(emailAddress: emailAddress, password: password))

        _ = handleSuccess(networkResponse, expectedStatusCode: 200)

        KeychainHelper.set(password, forKey: .password)
        try await fetchCredentials()

        return networkResponse
    }

    func refresh(refreshToken: String) async throws -> NetworkResponse<TokenPair> {
        let refreshTokenData = RefreshToken(refreshToken: refreshToken).encodeUsingJSONEncoder()
        let response: NetworkResponse<TokenPair> = try await NetworkManager.shared.post(url: Endpoint.refresh.urlString, body: refreshTokenData)

        try await fetchCredentials()
        return handleSuccess(response, expectedStatusCode: 200)
    }

    @discardableResult
    func refresh() async throws -> NetworkResponse<TokenPair>? {
        if let refreshToken = KeychainHelper.get(.refreshToken) {
            return try await refresh(refreshToken: refreshToken)
        }

        return nil
    }

    @discardableResult
    func logout(refreshToken: String) async throws -> NetworkResponse<ServerMessage> {
        let refreshTokenData = RefreshToken(refreshToken: refreshToken).encodeUsingJSONEncoder()
        let response: NetworkResponse<ServerMessage> = try await NetworkManager.shared.post(url: Endpoint.logout.urlString, body: refreshTokenData)

        dropCredentials()
        hasAccessToken = false

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

        let payloadData = ChangeEmailAddress(newEmailAddress: newEmailAddress).encodeUsingJSONEncoder()
        return try await NetworkManager.shared.patch(url: Endpoint.changeEmail.urlString, body: payloadData, headers: AuthenticationService.authorizationHeaders)
    }

    @discardableResult
    func changePassword(currentPassword: String, newPassword: String) async throws -> NetworkResponse<ServerMessage> {

        let payloadData = ChangePassword(currentPassword: currentPassword, newPassword: newPassword).encodeUsingJSONEncoder()
        return try await NetworkManager.shared.patch(url: Endpoint.changePassword.urlString, body: payloadData, headers: AuthenticationService.authorizationHeaders)
    }

    @discardableResult
    func requestOTP(emailAddress: String) async throws -> NetworkResponse<ServerMessage> {

        let payloadData = RequestOTP(emailAddress: emailAddress).encodeUsingJSONEncoder()
        return try await NetworkManager.shared.post(url: Endpoint.requestOTP.urlString, body: payloadData)
    }

    @discardableResult
    func requestOTP() async throws -> NetworkResponse<ServerMessage> {
        let credentials: UserCredential? = Database.shared[.credentials]
        return try await requestOTP(emailAddress: credentials?.emailAddress ?? "")
    }

    @discardableResult
    func verifyOTP(emailAddress: String, otp: String) async throws -> NetworkResponse<ServerMessage> {

        let payloadData = VerifyOTP(emailAddress: emailAddress, otp: otp).encodeUsingJSONEncoder()
        return try await NetworkManager.shared.post(url: Endpoint.verifyOTP.urlString, body: payloadData)
    }

    @discardableResult
    func verifyOTP(otp: String) async throws -> NetworkResponse<ServerMessage> {
        let credentials: UserCredential? = Database.shared[.credentials]
        return try await verifyOTP(emailAddress: credentials?.emailAddress ?? "", otp: otp)
    }

    @discardableResult
    func delete() async throws -> NetworkResponse<Bool> {

        let networkResponse: NetworkResponse<Bool> = try await NetworkManager.shared.delete(url: Endpoint.delete.urlString, headers: AuthenticationService.authorizationHeaders)
        if networkResponse.success {

            dropCredentials()
        } else {}
        return networkResponse
    }

    func appleLogin(idToken: String, existingEmailAddress: String? = nil) async throws -> NetworkResponse<TokenPair> {
        let payloadData = ThirdPartyLogin(idToken: idToken, existingEmailAddress: existingEmailAddress).encodeUsingJSONEncoder()
        let response: NetworkResponse<TokenPair> = try await NetworkManager.shared.post(url: Endpoint.appleLogin.urlString, body: payloadData)

        try await fetchCredentials()
        return handleSuccess(response, expectedStatusCode: 200)
    }

    @discardableResult
    func me() async throws -> NetworkResponse<UserModel> {
        let response: NetworkResponse<UserModel> = try await NetworkManager.shared.get(url: Endpoint.me.urlString, headers: AuthenticationService.authorizationHeaders)

        userModel = response.data
        return response
    }

    @discardableResult
    func fetchCredentials() async throws -> NetworkResponse<UserCredential> {
        let response: NetworkResponse<UserCredential> = try await NetworkManager.shared.get(url: Endpoint.credentials.urlString, headers: AuthenticationService.authorizationHeaders)

        credentials = response.data
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

    private func handleSuccess<T: TokenContaining>(_ response: NetworkResponse<T>, expectedStatusCode: Int) -> NetworkResponse<T> {
        let data = response.data
        persistSession(accessToken: data.accessToken, refreshToken: data.refreshToken, expiresAtTimestamp: data.expiresAtTimestamp)

        tokenPair = data
        return response
    }

    private func persistSession(accessToken: String, refreshToken: String, expiresAtTimestamp: TimeInterval) {
        KeychainHelper.set(accessToken, forKey: .accessToken)
        KeychainHelper.set(refreshToken, forKey: .refreshToken)

        hasAccessToken = KeychainHelper.get(.accessToken)?.isEmpty == false && expiresAtTimestamp > Date.now.timeIntervalSince1970
    }

    private func prepareCredentialsData(emailAddress: String, password: String) -> Data? {
        LoginCredentials(emailAddress: emailAddress, password: password).encodeUsingJSONEncoder()
    }

    private func dropCredentials() {
        KeychainHelper.remove(.accessToken)
        KeychainHelper.remove(.refreshToken)

        hasAccessToken = false
        userModel = nil
    }

    private func loginWithApple(token: String) async throws -> NetworkResponse<TokenPair> {
        let payload = ThirdPartyLogin(idToken: token, existingEmailAddress: nil)
        guard let data = payload.encodeUsingJSONEncoder() else {
            fatalError()
        }

        let response: NetworkResponse<TokenPair> = try await NetworkManager.shared.post(url: Endpoint.appleLogin.urlString, body: data)

        try await fetchCredentials()
        return handleSuccess(response, expectedStatusCode: 200)
    }
}
