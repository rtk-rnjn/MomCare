import BackgroundTasks
import SwiftUI
import Combine
import OSLog
import UIKit
import UserNotifications

private let refreshTokenBackgroundTaskIdentifier = "com.MomCare.BackgroundTask.RefreshToken"
private let logger: Logger = .init(subsystem: "com.MomCare.AppDelegate", category: "AppDelegate")

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        logger.info("App launched with options: \(launchOptions.debugDescription)")

        UNUserNotificationCenter.current().delegate = self

        UISegmentedControl.appearance().selectedSegmentTintColor = .white
        UISegmentedControl.appearance().backgroundColor = UIColor(Color.CustomColors.mutedRaspberry)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.CustomColors.mutedRaspberry)], for: .selected)

        return true
    }

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
