//

//  ContentHandler+DataTransferObjects.swift

//  MomCare

//

//  Created by RITIK RANJAN on 18/06/25.

//

import Foundation

struct Tip: Codable, Sendable {

    enum CodingKeys: String, CodingKey {

        case todaysFocus = "todays_focus"

        case dailyTip = "daily_tip"

        case createdAt = "created_at"

    }

    var todaysFocus: String

    var dailyTip: String

    var createdAt: Date?

}

struct FoodSearchQuery: Codable, Sendable {

    enum CodingKeys: String, CodingKey {

        case foodName = "food_name"

        case limit

    }

    var foodName: String

    var limit: Int = 10

}

struct S3Response: Codable, Sendable {

    enum CodingKeys: String, CodingKey {

        case uri = "link"

        case expiryAt = "link_expiry_at"

    }

    var uri: String

    var expiryAt: Date?

}
