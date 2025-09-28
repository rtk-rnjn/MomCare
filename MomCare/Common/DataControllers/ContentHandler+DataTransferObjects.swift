//
//  ContentHandler+DataTransferObjects.swift
//  MomCare
//
//  Created by RITIK RANJAN on 18/06/25.
//

import Foundation

/// Represents a daily motivational or informational tip for the user.
///
/// This model is typically returned from the backend as part of the
/// "Daily Tips" or "Focus of the Day" API.
/// - Important: Uses snake_case keys when decoded from JSON.
struct Tip: Codable, Sendable {

    /// Coding keys mapping the Swift properties to the backend JSON keys.
    enum CodingKeys: String, CodingKey {
        case todaysFocus = "todays_focus"
        case dailyTip = "daily_tip"
        case createdAt = "created_at"
    }

    /// The suggested focus area for today (e.g., *hydration*, *light exercise*).
    var todaysFocus: String

    /// A short health or wellness tip message to display to the user.
    var dailyTip: String

    /// Timestamp when this tip was created on the server.
    /// - Note: Optional because not all responses guarantee this field.
    var createdAt: Date?
}

/// Represents a query payload for searching foods in the nutrition database.
///
/// Encoded and sent to the backend when the user searches for food items.
/// - Important: Uses snake_case keys when encoded.
struct FoodSearchQuery: Codable, Sendable {

    enum CodingKeys: String, CodingKey {
        case foodName = "food_name"
        case limit
    }

    /// The name of the food item being searched (e.g., *apple*, *rice*).
    var foodName: String

    /// Maximum number of search results to return.
    /// - Default: `10`
    var limit: Int = 10
}

/// Represents the response from the server after uploading or requesting
/// a file stored in S3.
///
/// Typically used when fetching pre-signed URLs for media or document storage.
/// - Important: Uses snake_case keys when decoded from JSON.
struct S3Response: Codable, Sendable {

    enum CodingKeys: String, CodingKey {
        case uri = "link"
        case expiryAt = "link_expiry_at"
    }

    /// The pre-signed S3 URL for accessing the file.
    var uri: String

    /// Expiration time of the provided S3 link.
    /// - Note: Optional because the server may omit this field for
    /// non-expiring links.
    var expiryAt: Date?
}
