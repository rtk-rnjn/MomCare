import Foundation
import SwiftData
import UIKit

enum ExerciseLevel: String, Codable, Sendable {
    case advanced = "Advanced"
    case beginner = "Beginner"
    case intermediate = "Intermediate"
}

struct ExerciseModel: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case _id
        case name
        case level
        case description
        case week
        case tags
        case targetedBodyParts = "targeted_body_parts"
        case imageNameUri = "image_name_uri"
        case videoDurationSeconds = "video_duration_seconds"
    }

    var _id: String

    var name: String
    var level: ExerciseLevel
    var description: String
    var week: String
    var tags: [String]
    var targetedBodyParts: [String]
    var imageNameUri: String?
    var videoDurationSeconds: TimeInterval

    var image: UIImage? {
        get async {
            try? await UIImage.getOrFetch(from: imageNameUri ?? "")
        }
    }

    var humanReadableDuration: String {
        let minutes = Int(videoDurationSeconds) / 60
        let seconds = Int(videoDurationSeconds) % 60
        if minutes > 0, seconds > 0 {
            return "\(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes) min"
        } else {
            return "\(seconds)s"
        }
    }
}

struct UserExerciseModel: Codable, Sendable, Identifiable, Equatable {
    enum CodingKeys: String, CodingKey {
        case _id
        case userId = "user_id"
        case exerciseId = "exercise_id"
        case addedAtTimestamp = "added_at_timestamp"
        case videoDurationCompletedSeconds = "video_duration_completed_seconds"
    }

    var _id: String
    var userId: String
    var exerciseId: String
    var addedAtTimestamp: TimeInterval
    var videoDurationCompletedSeconds: TimeInterval

    var id: String {
        _id
    }
}
