import CryptoKit
import Foundation
import UIKit

private let appGroup = "group.MomCare"

enum ValidDatabaseKeys {
    case userModel
    case foodModel(String)
    case exerciseModel(String)
    case songModel(String)

    case breathingProgress(Date)

    case dailyInsight(Date)
    case mealPlan(Date)
    case userExercises(Date)

    case credentials
    case tokenPair

    case calendarIdentifier

    // MARK: Internal

    var rawValue: String {
        switch self {
        case .userModel:
            "userModel"
        case let .foodModel(id):
            "food_\(id)"
        case let .exerciseModel(id):
            "exercise_\(id)"
        case let .songModel(id):
            "song_\(id)"
        case let .breathingProgress(date):
            "breathing_\(date.timeIntervalSince1970)"
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
        case .calendarIdentifier:
            "calendarIdentifier"
        }
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

    subscript<T: Codable>(_ key: ValidDatabaseKeys) -> T? {
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

            guard let data = newValue.encodeUsingJSONEncoder() else {
                return
            }

            userDefaults.set(data, forKey: key.rawValue)
        }
    }

    // MARK: Private

    private let userDefaults: UserDefaults
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

        guard let data = image.jpegData(compressionQuality: 1) else { return }
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
