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

    @Published var userModel: UserModel? {
        didSet {
            database[.userModel] = userModel
        }
    }

    func handleSuccess<T: TokenContaining>(_ response: NetworkResponse<T>, expectedStatusCode: Int, emailAddress: String? = nil) -> NetworkResponse<T> {
        let success = response.errorMessage == nil && response.statusCode == expectedStatusCode && response.data != nil
        guard success, let data = response.data else {
            hasAccessToken = false
            return response
        }

        persistSession(accessToken: data.accessToken, refreshToken: data.refreshToken, expiresAtTimestamp: data.expiresAtTimestamp, emailAddress: emailAddress)

        return response
    }

    @discardableResult
    func register(emailAddress: String, password: String) async throws -> NetworkResponse<RegistrationResponse> {
        let response: NetworkResponse<RegistrationResponse> = try await NetworkManager.shared.post(url: Endpoint.register.urlString, body: prepareCredentialsData(emailAddress: emailAddress, password: password))

        return handleSuccess(response, expectedStatusCode: 201, emailAddress: emailAddress)
    }

    @discardableResult
    func login(emailAddress: String, password: String) async throws -> NetworkResponse<TokenPair> {
        let networkResponse: NetworkResponse<TokenPair> = try await NetworkManager.shared.post(url: Endpoint.login.urlString, body: prepareCredentialsData(emailAddress: emailAddress, password: password))

        let response = handleSuccess(networkResponse, expectedStatusCode: 200, emailAddress: emailAddress)
        if response.statusCode == 200 {
            _ = try? await me()
        }

        KeychainHelper.set(password, forKey: .password)
        return networkResponse
    }

    @discardableResult
    func autoLogin() async -> NetworkResponse<TokenPair>? {
        let emailAddress: String? = database[.emailAddress]
        let password: String? = KeychainHelper.get(.password)

        if let emailAddress, let password {
            return try? await login(emailAddress: emailAddress, password: password)
        }

        return nil
    }

    func refresh(refreshToken: String) async throws -> NetworkResponse<TokenPair> {
        let refreshTokenData = RefreshToken(refreshToken: refreshToken).encodeUsingJSONEncoder()
        let response: NetworkResponse<TokenPair> = try await NetworkManager.shared.post(url: Endpoint.refresh.urlString, body: refreshTokenData)

        return handleSuccess(response, expectedStatusCode: 200)
    }

    func refresh() async throws {
        if let refreshToken = KeychainHelper.get(.refreshToken) {
            _ = try await refresh(refreshToken: refreshToken)
        }
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
        height: FieldType<Double> = .unset,
        prePregnancyWeight: FieldType<Double> = .unset,
        currentWeight: FieldType<Double> = .unset,
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
        let response: NetworkResponse<ServerMessage> = try await NetworkManager.shared.patch(url: Endpoint.changeEmail.urlString, body: payloadData, headers: AuthenticationService.authorizationHeaders)

        if response.errorMessage == nil, response.statusCode == 200, let refreshToken = KeychainHelper.get(.refreshToken) {
            try await logout(refreshToken: refreshToken)
        }

        return response
    }

    @discardableResult
    func changePassword(currentPassword: String, newPassword: String) async throws -> NetworkResponse<ServerMessage> {
        let payloadData = ChangePassword(currentPassword: currentPassword, newPassword: newPassword).encodeUsingJSONEncoder()
        let response: NetworkResponse<ServerMessage> = try await NetworkManager.shared.patch(url: Endpoint.changePassword.urlString, body: payloadData, headers: AuthenticationService.authorizationHeaders)

        if response.errorMessage == nil, response.statusCode == 200, let refreshToken = KeychainHelper.get(.refreshToken) {
            try await logout(refreshToken: refreshToken)
        }

        return response
    }

    @discardableResult
    func requestOTP(emailAddress: String) async throws -> NetworkResponse<ServerMessage> {
        let payloadData = RequestOTP(emailAddress: emailAddress).encodeUsingJSONEncoder()
        return try await NetworkManager.shared.post(url: Endpoint.requestOTP.urlString, body: payloadData)
    }

    @discardableResult
    func requestOTP() async throws -> NetworkResponse<ServerMessage> {
        let emailAddress = database[.emailAddress] ?? ""
        return try await requestOTP(emailAddress: emailAddress)
    }

    @discardableResult
    func verifyOTP(emailAddress: String, otp: String) async throws -> NetworkResponse<ServerMessage> {
        let payloadData = VerifyOTP(emailAddress: emailAddress, otp: otp).encodeUsingJSONEncoder()
        return try await NetworkManager.shared.post(url: Endpoint.verifyOTP.urlString, body: payloadData)
    }

    @discardableResult
    func verifyOTP(otp: String) async throws -> NetworkResponse<ServerMessage> {
        let emailAddress = database[.emailAddress] ?? ""
        return try await verifyOTP(emailAddress: emailAddress, otp: otp)
    }

    @discardableResult
    func delete() async throws -> NetworkResponse<Bool> {
        let networkResponse: NetworkResponse<Bool> = try await NetworkManager.shared.delete(url: Endpoint.delete.urlString, headers: AuthenticationService.authorizationHeaders)
        if networkResponse.success {
            dropCredentials()
        }
        return networkResponse
    }

    func googleLogin(idToken: String, existingEmailAddress: String? = nil) async throws -> NetworkResponse<TokenPair> {
        let payloadData = ThirdPartyLogin(idToken: idToken, existingEmailAddress: existingEmailAddress).encodeUsingJSONEncoder()
        let response: NetworkResponse<TokenPair> = try await NetworkManager.shared.post(url: Endpoint.googleLogin.urlString, body: payloadData)

        return handleSuccess(response, expectedStatusCode: 200, emailAddress: existingEmailAddress)
    }

    func appleLogin(idToken: String, existingEmailAddress: String? = nil) async throws -> NetworkResponse<TokenPair> {
        let payloadData = ThirdPartyLogin(idToken: idToken, existingEmailAddress: existingEmailAddress).encodeUsingJSONEncoder()
        let response: NetworkResponse<TokenPair> = try await NetworkManager.shared.post(url: Endpoint.appleLogin.urlString, body: payloadData)

        return handleSuccess(response, expectedStatusCode: 200, emailAddress: existingEmailAddress)
    }

    @discardableResult
    func me() async throws -> NetworkResponse<UserModel> {
        let response: NetworkResponse<UserModel> = try await NetworkManager.shared.get(url: Endpoint.me.urlString, headers: AuthenticationService.authorizationHeaders)

        if response.errorMessage == nil, response.statusCode == 200, let userModel = response.data {
            DispatchQueue.main.async {
                self.userModel = userModel
            }
            database[.userModel] = userModel
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

    private func persistSession(accessToken: String, refreshToken: String, expiresAtTimestamp: TimeInterval, emailAddress: String? = nil) {
        KeychainHelper.set(accessToken, forKey: .accessToken)
        KeychainHelper.set(refreshToken, forKey: .refreshToken)

        if let emailAddress {
            database[.emailAddress] = emailAddress
        }
        database[.accessTokenExpiresAtTimestamp] = expiresAtTimestamp

        hasAccessToken = KeychainHelper.get(.accessToken)?.isEmpty == false && expiresAtTimestamp > Date.now.timeIntervalSince1970
    }

    private func prepareCredentialsData(emailAddress: String, password: String) -> Data? {
        let credentialsModel = CredentialsModel(emailAddress: emailAddress, password: password)

        return credentialsModel.encodeUsingJSONEncoder()
    }

    private func dropCredentials() {
        KeychainHelper.remove(.accessToken)
        KeychainHelper.remove(.refreshToken)
        database.delete(ValidDatabaseKeys.emailAddress.rawValue)
        database.delete(ValidDatabaseKeys.accessTokenExpiresAtTimestamp.rawValue)

        userModel?._id = ""
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
