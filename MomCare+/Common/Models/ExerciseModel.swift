//
//  ExerciseModel.swift
//  MomCare+
//
//  Created by Aryan singh on 12/02/26.
//

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

    var exerciseModel: ExerciseModel? {
        get async {
            guard let networkResponse = try? await ContentService.shared.fetchExercise(id: exerciseId) else {
                return nil
            }
            return networkResponse.data
        }
    }

    var completionPercentage: Double {
        get async {
            guard let exerciseModel = await exerciseModel else { return 0 }
            guard exerciseModel.videoDurationSeconds > 0 else { return 0 }
            return min(videoDurationCompletedSeconds / exerciseModel.videoDurationSeconds, 1.0)
        }
    }

    var isCompleted: Bool {
        get async {
            await completionPercentage >= 1.0
        }
    }

    var url: URL? {
        get async {
            let networkResponse = try? await ContentService.shared.fetchExerciseStreamUri(id: exerciseId)
            if let networkResponse, let urlString = networkResponse.data?.detail {
                return URL(string: urlString)
            }

            return nil
        }
    }

    static func totalCompletion(from userExercises: [UserExerciseModel]) async -> Int {
        await withTaskGroup(of: Bool.self) { group in
            for exercise in userExercises {
                group.addTask {
                    await exercise.isCompleted
                }
            }

            var count = 0

            for await result in group where result {
                count += 1
            }

            return count
        }
    }
}
