//
//  Utils.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/02/25.
//

import Foundation
import UIKit
import Network

enum AlertType {
    case ok
    case okCancel
}

struct AlertActionHandler {
    let title: String
    let style: UIAlertAction.Style
    let handler: ((UIAlertAction) -> Void)?
}

let dimViewTag = 100

enum Utils {
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

    public static func save<T>(forKey key: UserDefaultsKey, withValue value: T) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

    public static func get<T>(fromKey: String, withDefaultValue: Any? = nil) -> T? {
        return UserDefaults.standard.value(forKey: fromKey) as? T ?? withDefaultValue as? T
    }

    public static func remove(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
