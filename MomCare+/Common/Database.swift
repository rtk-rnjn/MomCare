import CryptoKit
import EventKit
import Foundation
import OSLog
import UIKit

private let logger: Logger = MomCareLogger.database

private let appGroup = "group.MomCare"

enum ValidDatabaseKeys {
    case userModel
    case foodModel(String)
    case exerciseModel(String)
    case songModel(String)

    case dailyInsight(Date)
    case mealPlan(Date)
    case userExercises(Date)

    case credentials
    case tokenPair

    case calendarIdentifier(EKEntityType)

    // MARK: Internal

    var rawValue: String {
        let value = switch self {
        case .userModel:
            "userModel"
        case let .foodModel(id):
            "food_\(id)"
        case let .exerciseModel(id):
            "exercise_\(id)"
        case let .songModel(id):
            "song_\(id)"
        case let .dailyInsight(date):
            "dailyInsight_\(date.timeIntervalSince1970)"
        case let .mealPlan(date):
            "mealPlan_\(date.timeIntervalSince1970)"
        case let .userExercises(date):
            "userExercises_\(date.timeIntervalSince1970)"
        case .credentials:
            "credentials"
        case .tokenPair:
            "tokenPair"
        case let .calendarIdentifier(ekEntityType):
            switch ekEntityType {
            case .event:
                "calendarIdentifier_event"
            case .reminder:
                "calendarIdentifier_reminder"
            @unknown default:
                "calendarIdentifier_unknown"
            }
        }

        return "MomCare_\(value)"
    }
}

@MainActor
final class Database {
    // MARK: Lifecycle

    private init() {
        let baseURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        directory = baseURL.appendingPathComponent("ImageCache", isDirectory: true)

        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        userDefaults = UserDefaults(suiteName: appGroup) ?? .standard
        userDefaults.register(defaults: ["isFirstLaunch": true])
    }

    // MARK: Internal

    static let shared: Database = .init()

    let userDefaults: UserDefaults

    func find<T: Codable & Sendable>(withMatchingRegex pattern: String) -> [T] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }

        var results = [T]()

        for key in userDefaults.dictionaryRepresentation().keys {
            let range = NSRange(key.startIndex..<key.endIndex, in: key)

            if regex.firstMatch(in: key, options: [], range: range) != nil,
               let data = userDefaults.data(forKey: key),
               let decoded = try? data.decodeUsingJSONDecoder() as T {
                results.append(decoded)
            }
        }

        return results
    }

    func purge() {
        let keysNotToDeletePrefix: [String] = [
            "MomCare_exercise_",
            "MomCare_song_",
            "MomCare_food_",
            "MomCare_calendarIdentifier_"
        ]

        let keysToDeletePrefix = "MomCare_"

        for key in userDefaults.dictionaryRepresentation().keys where key.hasPrefix(keysToDeletePrefix) && !keysNotToDeletePrefix.contains(where: { key.hasPrefix($0) }) {
            logger.info("Purging key: \(key, privacy: .public)")
            userDefaults.removeObject(forKey: key)
        }
    }

    subscript<T: Codable & Sendable>(_ key: ValidDatabaseKeys) -> T? {
        get {
            guard let data = userDefaults.data(forKey: key.rawValue) else {
                return nil
            }

            return try? data.decodeUsingJSONDecoder()
        }
        set {
            if newValue == nil {
                userDefaults.set(nil, forKey: key.rawValue)
                return
            }

            guard let data = try? newValue.encodeUsingJSONEncoder() else {
                return
            }

            logger.debug("Storing value for key: \(key.rawValue, privacy: .public)")
            userDefaults.set(data, forKey: key.rawValue)
        }
    }

    // MARK: Private

    private let directory: URL
}

extension Database {
    func image(for url: URL) -> UIImage? {
        let key = cacheKey(for: url)
        let fileURL = directory.appendingPathComponent(key)

        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }

        return UIImage(data: data)
    }

    func storeUIImage(_ image: UIImage, for url: URL) {
        let key = cacheKey(for: url)
        let fileURL = directory.appendingPathComponent(key)

        guard let data = image.jpegData(compressionQuality: 1) else {
            return
        }

        try? data.write(to: fileURL)
    }

    private func cacheKey(for url: URL) -> String {
        let normalized = url.normalizedForCache
        let hash = SHA256.hash(data: Data(normalized.utf8))
        return hash.compactMap { unsafe String(format: "%02x", $0) }.joined()
    }
}

extension Database {
    func pregnancyProgress() -> PregnancyProgress? {
        guard let user: UserModel = self[.userModel]
        else {
            return nil
        }

        return user.pregnancyProgress()
    }
}
