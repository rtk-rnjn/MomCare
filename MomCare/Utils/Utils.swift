//
//  Utils.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/02/25.
//

import Foundation
import UIKit
import Network
import UserNotifications
import Security

enum AlertType {
    case ok
    case okCancel
}

struct AlertActionHandler {
    var title: String
    var style: UIAlertAction.Style
    var handler: ((UIAlertAction) -> Void)?
}

enum Utils {

    // MARK: Public

    @MainActor public static func getAlert(title: String, message: String, actions: [AlertActionHandler]? = nil) -> UIAlertController {
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

    public static func isConnectedToNetwork() -> Bool {
        // https://stackoverflow.com/a/55039596

        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
        return monitor.currentPath.status == .satisfied
    }

    // MARK: - User Defaults

    public static func save<T>(forKey key: String, withValue value: T?) {
        if let value {
            UserDefaults.standard.set(value, forKey: key)
        }
    }

    public static func get<T>(fromKey: String, withDefaultValue: Any? = nil) -> T? {
        return UserDefaults.standard.value(forKey: fromKey) as? T ?? withDefaultValue as? T
    }

    public static func remove(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

    public static func createNotification(title: String? = nil, body: String? = nil, date: Date? = nil, userInfo: [String: Any]? = nil) {
        let content = UNMutableNotificationContent()

        content.title = title ?? "MomCare"
        content.body = body ?? "Reminder"
        content.sound = .defaultCritical
        content.interruptionLevel = .timeSensitive
        content.userInfo = userInfo ?? [:]

        let timeInterval = Date().relativeInterval(from: date)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: Internal

    static func pregnancyWeekAndDay(dueDate: Date) -> (week: Int, day: Int, trimester: String)? { // swiftlint:disable:this large_tuple
        let calendar = Calendar.current
        let today = Date()

        guard let lmp = calendar.date(byAdding: .day, value: -280, to: dueDate) else {
            return nil
        }
        let daysElapsed = calendar.dateComponents([.day], from: lmp, to: today).day ?? 0
        guard daysElapsed >= 0, daysElapsed <= 280 else {
            return nil
        }

        let weekNumber = daysElapsed / 7 + 1
        let dayNumber = daysElapsed % 7 + 1

        let trimester: String
        switch weekNumber {
        case 1...12:
            trimester = "I"
        case 13...27:
            trimester = "II"
        case 28...40:
            trimester = "III"
        default:
            return nil
        }

        return (week: weekNumber, day: dayNumber, trimester: trimester)
    }

    static func getCaloriesGoal(trimester: String) -> Double {
        switch trimester {
        case "I":
            return 1700
        case "II":
            return 1830
        case "III":
            return 2400
        default:
            return 1
        }
    }
}

enum KeychainHelper {
    // I have no idea, how any of these function actually works
    // https://www.avanderlee.com/swift/discardableresult/
    @discardableResult
    public static func set(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

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

        if status == errSecSuccess {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        return nil
    }

    @discardableResult
    public static func remove(_ key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }
}
