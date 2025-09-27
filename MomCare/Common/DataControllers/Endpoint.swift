//
//  Endpoint.swift
//  MomCare
//
//  Created by RITIK RANJAN on 01/06/25.
//

import Foundation

private let baseURLString = "http://ec2-3-110-142-208.ap-south-1.compute.amazonaws.com:8000"

enum Endpoint: String {
    // Authentication
    case register = "/auth/register"
    case login = "/auth/login"
    case refresh = "/auth/refresh"
    case update = "/auth/update"
    case updateMedicalData = "/auth/update/medical-data"
    case fetch = "/auth/fetch"

    // Meta
    case meta = "/meta/"
    case health = "/meta/health"
    case version = "/meta/version"
    case ping = "/meta/ping"

    // Content
    case plan = "/content/plan"
    case search = "/content/search"
    case searchFoodName = "/content/search/food-name"
    case searchFoodImage = "/content/search/food-name/%@/image"
    case searchSymptoms = "/content/search/symptoms"
    case tips = "/content/tips"
    case exercises = "/content/exercises"
    case trimesterData = "/content/trimester-data"

    // Content S3
    case contentS3File = "/content/s3/file/%@"
    case contentS3Files = "/content/s3/files/%@"
    case contentS3Directories = "/content/s3/directories/%@"
    case contentS3Song = "/content/s3/song/%@"

    case contentQuotesMood = "/content/quotes/%@"
    case contentYoutube = "/content/youtube"

    // OTP Auth
    case reqeustOTP = "/auth/otp"
    case verifyOTP = "/auth/otp/verify"
}

extension Endpoint {
    var urlString: String {
        return baseURLString + rawValue
    }

    func urlString(with parameters: String...) -> String {
        return unsafe String(format: urlString, arguments: parameters)
    }
}
