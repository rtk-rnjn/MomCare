import CryptoKit
import Foundation
import UIKit

private let appGroup = "com.MomCare"

enum ValidDatabaseKeys {
    case accessTokenExpiresAtTimestamp
    case emailAddress
    case userModel
    case food(String)
    case exercise(String)
    case breathing(Date)

    // MARK: Internal

    var rawValue: String {
        switch self {
        case .accessTokenExpiresAtTimestamp:
            "accessTokenExpiresAtTimestamp"
        case .emailAddress:
            "emailAddress"
        case .userModel:
            "userModel"
        case let .food(id):
            "food_\(id)"
        case let .exercise(id):
            "exercise_\(id)"
        case let .breathing(date):
            "breathing_\(date.timeIntervalSince1970)"
        }
    }
}

class Database {

    // MARK: Lifecycle

    init() {
        userDefaults.register(defaults: ["isFirstLaunch": true])
        let baseURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        directory = baseURL.appendingPathComponent("ImageCache", isDirectory: true)

        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    // MARK: Internal

    subscript<T: Codable>(_ key: ValidDatabaseKeys) -> T? {
        get {
            get(key.rawValue)
        }
        set {
            set(newValue, forKey: key.rawValue)
        }
    }

    func get<T: Codable>(_ key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }

        return try? data.decodeUsingJSONDecoder()
    }

    func set(_ value: (some Codable)?, forKey key: String) {
        if value == nil {
            userDefaults.set(nil, forKey: key)
            return
        }

        guard let data = value.encodeUsingJSONEncoder() else {
            return
        }

        userDefaults.set(data, forKey: key)
    }

    func delete(_ key: String) {
        userDefaults.removeObject(forKey: key)
    }

    func delete(_ key: ValidDatabaseKeys) {
        userDefaults.removeObject(forKey: key.rawValue)
    }

    // MARK: Private

    private let userDefaults = UserDefaults(suiteName: appGroup) ?? .standard
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
    func listFoods() -> [FoodItemModel] {
        let keys = userDefaults.dictionaryRepresentation().keys.filter { $0.starts(with: "food_") }
        return keys.compactMap { get($0) as FoodItemModel? }
    }
}
