//
//  Endpoint.swift
//  MomCare
//
//  Created by RITIK RANJAN on 01/06/25.
//

import Foundation

private let baseURLString = "http://13.233.139.216:8000"

enum Endpoint: String {
    // Authentication
    case register = "/auth/register"
    case login = "/auth/login"
    case refresh = "/auth/refresh"
    case update = "/auth/update"
    case fetch = "/auth/fetch"

    // Meta
    case meta = "/meta/"
    case health = "/meta/health"
    case version = "/meta/version"
    case ping = "/meta/ping"

    // Content
    case plan = "/content/plan"
    case search = "/content/search"
    case tips = "/content/tips"

    // Content S3
    case contentS3File = "/content/s3/file/%@"
    case contentS3Files = "/content/s3/files/%@"
    case contentS3Directories = "/content/s3/directories/%@"
    case contentS3Song = "/content/s3/song/%@"

    case contentQuotesMood = "/content/quotes/%@"
}

extension Endpoint {
    var urlString: String {
        return baseURLString + rawValue
    }

    func urlString(with parameters: String...) -> String {
        return String(format: urlString, arguments: parameters)
    }
}
