//
//  Utils.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/02/25.
//

import Foundation
import Network
import UserNotifications
import Security

#if os(iOS)
import UIKit
#endif // os(iOS)

/// Defines the type of alert to display.
enum AlertType {
    case ok
    case okCancel
}

/// Represents an action to display in an alert (iOS only).
#if os(iOS)
struct AlertActionHandler {
    var title: String
    var style: UIAlertAction.Style
    var handler: ((UIAlertAction) -> Void)?
}
#endif // os(iOS)

/// A collection of general-purpose utility functions used throughout the MomCare app.
enum Utils {

// MARK: Public

#if os(iOS)
    /// Creates and returns a pre-configured `UIAlertController`.
    ///
    /// - Parameters:
    ///   - title: The alert's title.
    ///   - message: The alert's body message.
    ///   - actions: Optional array of `AlertActionHandler` objects. If `nil`, a default "OK" action is added.
    /// - Returns: A `UIAlertController` ready to be presented.
    @MainActor
    public static func getAlert(
        title: String,
        message: String,
        actions: [AlertActionHandler]? = nil
    ) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        guard let actions else {
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            return alert
        }

        for action in actions {
            alert.addAction(UIAlertAction(title: action.title, style: action.style, handler: action.handler))
        }

        return alert
    }
#endif // os(iOS)

    /// Saves a value in `UserDefaults` for the specified key.
    ///
    /// - Parameters:
    ///   - key: The key to associate with the value.
    ///   - value: The value to save. If `nil`, nothing is stored.
    public static func save<T>(forKey key: String, withValue value: T?) {
        if let value {
            UserDefaults.standard.set(value, forKey: key)
        }
    }

    /// Retrieves a value from `UserDefaults`.
    ///
    /// - Parameters:
    ///   - fromKey: The key associated with the value.
    ///   - withDefaultValue: An optional default value if the key does not exist.
    /// - Returns: The stored value or the default value.
    public static func get<T>(fromKey: String, withDefaultValue: Any? = nil) -> T? {
        return UserDefaults.standard.value(forKey: fromKey) as? T ?? withDefaultValue as? T
    }

    /// Removes a value from `UserDefaults`.
    ///
    /// - Parameter key: The key to remove.
    public static func remove(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

    /// Creates a local notification.
    ///
    /// - Parameters:
    ///   - title: Optional title of the notification (default: "MomCare").
    ///   - body: Optional body message (default: "Reminder").
    ///   - date: Optional trigger date. If `nil`, triggers immediately.
    ///   - userInfo: Optional dictionary with extra info to include in the notification.
    public static func createNotification(
        title: String? = nil,
        body: String? = nil,
        date: Date? = nil,
        userInfo: [String: Any]? = nil
    ) {
        let content = UNMutableNotificationContent()
        content.title = title ?? "MomCare"
        content.body = body ?? "Reminder"
        content.sound = .defaultCritical
        content.interruptionLevel = .timeSensitive
        content.userInfo = userInfo ?? [:]

        let timeInterval = Date().relativeInterval(from: date) + 0.01
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: Internal

    /// Calculates the current pregnancy week, day, and trimester based on the due date.
    ///
    /// - Parameter dueDate: The expected delivery date.
    /// - Returns: A tuple `(week, day, trimester)` if the pregnancy is ongoing, otherwise `nil`.
    static func pregnancyWeekAndDay(dueDate: Date) -> (week: Int, day: Int, trimester: String)? { // swiftlint:disable:this large_tuple
        let calendar = Calendar.current
        let today = Date()

        // Calculate Last Menstrual Period (LMP) assuming a 280-day pregnancy
        guard let lmp = calendar.date(byAdding: .day, value: -280, to: dueDate) else { return nil }

        let daysElapsed = calendar.dateComponents([.day], from: lmp, to: today).day ?? 0
        guard daysElapsed >= 0, daysElapsed <= 280 else { return nil }

        let weekNumber = daysElapsed / 7 + 1
        let dayNumber = daysElapsed % 7 + 1

        let trimester: String
        switch weekNumber {
        case 1...12: trimester = "I"
        case 13...27: trimester = "II"
        case 28...40: trimester = "III"
        default: return nil
        }

        return (week: weekNumber, day: dayNumber, trimester: trimester)
    }

    /// Returns the recommended step goal for a specific pregnancy week.
    ///
    /// - Parameter week: The current pregnancy week.
    /// - Returns: The step goal in steps per day.
    static func getStepGoal(week: Int) -> Double {
        return 1200 // TODO: Update based on trimester and health recommendations
    }

    /// Returns the recommended workout goal asynchronously.
    ///
    /// - Returns: The number of workouts per week.
    static func getWorkoutGoal() async -> Double {
        return 2 // TODO: Update based on trimester and health recommendations
    }
}

/// A helper utility for storing, retrieving, and removing string values in the Keychain.
///
/// Uses `kSecClassGenericPassword` to securely store values associated with a specific key.
/// All operations return a boolean or optional string to indicate success or failure.
///
/// Example usage:
/// ```swift
/// KeychainHelper.set("mySecretValue", forKey: "userToken")
/// let token = KeychainHelper.get("userToken")
/// KeychainHelper.remove("userToken")
/// ```
enum KeychainHelper {

    /// Stores a string value in the Keychain for a given key.
    ///
    /// - Parameters:
    ///   - value: The string value to store.
    ///   - key: The unique key to associate with the value.
    /// - Returns: `true` if the value was successfully added, `false` otherwise.
    ///
    /// Notes:
    /// - Any existing value for the same key will be deleted before adding the new one.
    /// - Uses UTF-8 encoding to convert the string into `Data`.
    @discardableResult
    public static func set(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        // Delete any existing item for this key
        SecItemDelete(query as CFDictionary)

        // Add the new item
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    /// Retrieves a string value from the Keychain for a given key.
    ///
    /// - Parameter key: The key associated with the stored value.
    /// - Returns: The string value if it exists, otherwise `nil`.
    ///
    /// Notes:
    /// - Returns `nil` if the key does not exist or if the data cannot be converted to a string.
    @discardableResult
    public static func get(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    /// Removes a value from the Keychain for a given key.
    ///
    /// - Parameter key: The key associated with the value to remove.
    /// - Returns: `true` if the item was successfully removed, `false` otherwise.
    @discardableResult
    public static func remove(_ key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }
}
