import Foundation

struct CredentialsModel: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case emailAddress = "email_address"
        case password
    }

    var emailAddress: String
    var password: String
}

struct DailyInsightModel: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case todaysFocus = "todays_focus"
        case dailyTip = "daily_tip"
    }

    var todaysFocus: String
    var dailyTip: String
}

struct RegistrationResponse: Codable, Sendable, TokenContaining {
    enum CodingKeys: String, CodingKey {
        case emailAddress = "email_address"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAtTimestamp = "expires_at_timestamp"
    }

    var emailAddress: String
    var accessToken: String
    var refreshToken: String
    var expiresAtTimestamp: TimeInterval
}

struct TokenPair: Codable, Sendable, TokenContaining {
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAtTimestamp = "expires_at_timestamp"
    }

    var accessToken: String
    var refreshToken: String
    var expiresAtTimestamp: TimeInterval
}

struct ServerMessage: Codable, Sendable {
    let detail: String
}

struct TimestampRange: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case startTimestamp = "start_timestamp"
        case endTimestamp = "end_timestamp"
    }

    let startTimestamp: TimeInterval
    let endTimestamp: TimeInterval
}

struct RefreshToken: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }

    let refreshToken: String
}

struct ThirdPartyLogin: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case idToken = "id_token"
        case existingEmailAddress = "existing_email_address"
    }

    var idToken: String
    var existingEmailAddress: String?
}

struct ChangeEmailAddress: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case newEmailAddress = "new_email_address"
    }

    var newEmailAddress: String
}

struct RegisterDevice: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case deviceToken = "device_token"
    }

    var deviceToken: String
}

struct ChangePassword: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case currentPassword = "current_password"
        case newPassword = "new_password"
    }

    var currentPassword: String
    var newPassword: String
}

struct RequestOTP: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case emailAddress = "email_address"
    }

    var emailAddress: String
}

struct VerifyOTP: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case emailAddress = "email_address"
        case otp
    }

    var emailAddress: String
    var otp: String
}

struct ExerciseDuration: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case duration
    }

    var duration: TimeInterval
}
