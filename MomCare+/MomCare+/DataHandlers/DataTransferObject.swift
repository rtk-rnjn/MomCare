import Foundation

enum AuthenticationProvider: String, Codable, Sendable {
    case `internal`
    case apple
}

enum AccountStatus: String, Codable, Sendable {
    case active
    case locked
    case deleted
}

nonisolated struct LoginCredentials: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case emailAddress = "email_address"
        case password
    }

    let emailAddress: String
    let password: String
}

nonisolated struct DailyInsightModel: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case todaysFocus = "todays_focus"
        case dailyTip = "daily_tip"
    }

    let todaysFocus: String
    let dailyTip: String
}

nonisolated struct RegistrationResponse: Codable, Sendable, TokenContaining {
    enum CodingKeys: String, CodingKey {
        case emailAddress = "email_address"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAtTimestamp = "expires_at_timestamp"
    }

    let emailAddress: String
    let accessToken: String
    let refreshToken: String
    let expiresAtTimestamp: TimeInterval
}

nonisolated struct TokenPair: Codable, Sendable, TokenContaining {
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAtTimestamp = "expires_at_timestamp"
    }

    let accessToken: String
    let refreshToken: String
    let expiresAtTimestamp: TimeInterval
}

nonisolated struct ServerMessage: Codable, Sendable {
    let detail: String
}

nonisolated struct TimestampRange: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case startTimestamp = "start_timestamp"
        case endTimestamp = "end_timestamp"
    }

    let startTimestamp: TimeInterval
    let endTimestamp: TimeInterval
}

nonisolated struct RefreshToken: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }

    let refreshToken: String
}

nonisolated struct ThirdPartyLogin: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case idToken = "id_token"
        case existingEmailAddress = "existing_email_address"
    }

    let idToken: String
    let existingEmailAddress: String?
}

nonisolated struct ChangeEmailAddress: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case newEmailAddress = "new_email_address"
    }

    let newEmailAddress: String
}

nonisolated struct RegisterDevice: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case deviceToken = "device_token"
    }

    let deviceToken: String
}

nonisolated struct ChangePassword: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case currentPassword = "current_password"
        case newPassword = "new_password"
    }

    let currentPassword: String
    let newPassword: String
}

nonisolated struct RequestOTP: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case emailAddress = "email_address"
    }

    let emailAddress: String
}

typealias ForgetPassword = RequestOTP

nonisolated struct ResetPassword: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case emailAddress = "email_address"
        case otp
        case newPassword = "new_password"
    }

    let emailAddress: String
    let otp: String
    let newPassword: String
}

nonisolated struct VerifyOTP: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case emailAddress = "email_address"
        case otp
    }

    let emailAddress: String
    let otp: String
}

nonisolated struct ExerciseDuration: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case duration
    }

    let duration: TimeInterval
}

nonisolated struct UserCredential: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case emailAddress = "email_address"
        case appleIdentifier = "apple_id"
        case authenticationProviders = "authentication_providers"
        case accountStatus = "account_status"
        case verified = "verified_email"
    }

    var emailAddress: String?
    var appleIdentifier: String?
    var authenticationProviders: [AuthenticationProvider] = [.internal]
    var accountStatus: AccountStatus = .active
    var verified: Bool = false
}
