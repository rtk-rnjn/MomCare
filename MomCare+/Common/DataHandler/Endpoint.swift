import Foundation

private let baseURLString = "http://13.203.42.179/api"

enum Endpoint: String {
    // Authentication

    case register = "/v1/auth/register"
    case login = "/v1/auth/login"
    case me = "/v1/auth/me"
    case refresh = "/v1/auth/refresh"
    case logout = "/v1/auth/logout"
    case update = "/v1/auth/update"
    case delete = "/v1/auth/delete"
    case changeEmail = "/v1/auth/change-email"
    case changePassword = "/v1/auth/change-password"
    case requestOTP = "/v1/auth/request-otp"
    case verifyOTP = "/v1/auth/verify-otp"

    case googleLogin = "/v2/auth/ios/google-login"
    case appleLogin = "/v2/auth/ios/apple-login"

    // AI

    case generateTips = "/v1/ai/generate/tips"
    case generatePlan = "/v1/ai/generate/plan"
    case generateExercises = "/v1/ai/generate/exercises"
    case searchGeneratedTips = "/v1/ai/search/tips"
    case searchGeneratedPlan = "/v1/ai/search/plan"
    case searchGeneratedExercises = "/v1/ai/search/exercises"

    // Update

    case updateExerciseDuration = "/v1/update/exercise/%@"
    case updateFoodItemConsume = "/v1/update/myplan/%@/%@/%@/consume"
    case updateFoodItemUnconsume = "/v1/update/myplan/%@/%@/%@/unconsume"
    case updateAddFoodItem = "/v1/update/myplan/%@/%@/add/%@"
    case updateRemoveFoodItem = "/v1/update/myplan/%@/%@/remove/%@"

    // Utils

    case searchFoodItem = "/v1/utils/search/food"
    case searchSong = "/v1/utils/search/song"
    case searchExercise = "/v1/utils/search/exercise"

    case songs = "/v1/utils/songs"

    case fetchSong = "/v1/utils/songs/%@"
    case fetchSongUri = "/v1/utils/songs/%@/stream"

    case fetchExercise = "/v1/utils/exercises/%@"
    case fetchExerciseUri = "/v1/utils/exercises/%@/stream"

    case fetchFood = "/v1/utils/foods/%@"
    case fetchFoodImageUri = "/v1/utils/foods/%@/image"

    // Devices

    case apns = "/api/v2/devices/apns"
}

extension Endpoint {
    var urlString: String {
        baseURLString + rawValue
    }

    func urlString(with parameters: String...) -> String {
        return unsafe String(format: urlString, arguments: parameters)
    }
}
