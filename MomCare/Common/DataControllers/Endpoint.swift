//
//  Endpoint.swift
//  MomCare
//
//  Created by RITIK RANJAN on 01/06/25.
//

import Foundation

private let baseURLString = "http://13.233.252.95:8000"

enum Endpoint: String {
    // Authentication
    case register = "/v1/auth/register"
    case login = "/v1/auth/login"
    case refresh = "/v1/auth/refresh"
    case fetchUser = "/v1/auth/fetch-user"
    case updateUser = "/v1/auth/update-user"
    case deleteUser = "/v1/auth/delete-user"

    // OTP Authentication
    case sendOTP = "/v1/auth/otp"
    case verifyOTP = "/v1/auth/otp/verify"

    // AI Content
    case plan = "/v1/ai/plan"
    case tips = "/v1/ai/tips"
    case exercises = "/v1/ai/exercises"

    // Content
    case search = "/v1/content/search"
    case searchFoodName = "/v1/content/search/food-name"
    case searchFoodImage = "/v1/content/search/food-name/%@/image"
    case searchSymptoms = "/v1/content/search/symptoms"
    case trimesterData = "/v1/content/trimester-data"

    // Content S3
    case contentS3File = "/v1/content/s3/file/%@"
    case contentS3Files = "/v1/content/s3/files/%@"
    case contentS3Directories = "/v1/content/s3/directories/%@"
    case contentS3Song = "/v1/content/s3/song/%@"
    case contentQuotesMood = "/v1/content/quotes/%@"
}

extension Endpoint {
    var urlString: String {
        return baseURLString + rawValue
    }

    func urlString(with parameters: String...) -> String {
        return String(format: urlString, arguments: parameters)
    }
}
