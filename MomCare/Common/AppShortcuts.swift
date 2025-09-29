import Foundation
import UIKit
import OSLog

private let logger: Logger = .init(subsystem: "com.MomCare.AppShortcuts", category: "AppShortcuts`")
private let appBundleIdentifier = "com.MomCare."

@MainActor
class AppShortcuts: NSObject {

    // MARK: Internal

    static let shared: AppShortcuts = .init()

    let items: [UIApplicationShortcutItem] = TriTrackShortcut.allCases.map { $0.shortcutItem }

    @discardableResult
    func performAction(for shortcutItem: UIApplicationShortcutItem, in window: UIWindow?) -> Bool {
        for shortcutCase in TriTrackShortcut.allCases where shortcutItem.type == shortcutCase.type {
            handleTriTrackShortcutAction(shortcutCase, in: window)
            return true
        }

        return false
    }

    // MARK: Private

    private enum TriTrackShortcut: CaseIterable {
        case logSymptom
        case addAppointment

        // MARK: Internal

        var type: String {
            switch self {
            case .logSymptom: return appBundleIdentifier + "LogSymptom"
            case .addAppointment: return appBundleIdentifier + "AddAppointment"
            }
        }

        var title: String {
            switch self {
            case .logSymptom: return "Log Symptom"
            case .addAppointment: return "Add Appointment"
            }
        }

        var subtitle: String {
            switch self {
            case .logSymptom: return "Log your symptoms quickly"
            case .addAppointment: return "Schedule a new appointment"
            }
        }

        var userInfoKey: String {
            switch self {
            case .logSymptom: return "LogSymptomShortcut"
            case .addAppointment: return "AddAppointmentShortcut"
            }
        }

        var updateViewValue: Int {
            switch self {
            case .logSymptom: return 2
            case .addAppointment: return 1
            }
        }

        var tabIndex: Int { 2 }

        var shortcutItem: UIApplicationShortcutItem {
            .init(
                type: type,
                localizedTitle: title,
                localizedSubtitle: subtitle,
                icon: UIApplicationShortcutIcon(type: .date),
                userInfo: ["info": userInfoKey] as [String: any NSSecureCoding]
            )
        }
    }

    private func handleTriTrackShortcutAction(_ shortcut: TriTrackShortcut, in window: UIWindow? = nil) {
        guard let window,
              let rootViewController = window.rootViewController as? InitialTabBarController else {
            logger.error("Could not find InitialTabBarController as root view controller.")
            return
        }

        rootViewController.selectedIndex = shortcut.tabIndex

        guard let navController = rootViewController.selectedViewController as? UINavigationController,
              let viewController = navController.viewControllers.first as? TriTrackViewController else {
            logger.error("Could not find TriTrackViewController in selected tab.")
            return
        }

        _ = viewController.view
        viewController.updateView(with: shortcut.updateViewValue)

        viewController.performSegue(withIdentifier: "segueShowTriTrackAddEventViewController", sender: nil)
    }

}
