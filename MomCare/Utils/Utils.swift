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

let dimViewTag = 100

enum Utils {
    @MainActor public static func getAlert(type: AlertType, title: String, message: String, okHandler: ((UIAlertAction) -> Void)? = nil, cancelHandler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        switch type {
        case .ok:
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: okHandler))
        case .okCancel:
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: okHandler))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: cancelHandler))
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

    public static func save<T>(key: String, value: T) {
        UserDefaults.standard.set(value, forKey: key)
    }

    public static func get<T>(key: String, defaultValue: Any? = nil) -> T? {
        return UserDefaults.standard.value(forKey: key) as? T ?? defaultValue as? T
    }

    public static func remove(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
