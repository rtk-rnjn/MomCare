import BackgroundTasks
import Combine
import GoogleSignIn
import OSLog
import UIKit
import UserNotifications

private let refreshTokenBackgroundTaskIdentifier = "com.MomCare.BackgroundTask.RefreshToken"
private let logger: Logger = .init(subsystem: "com.MomCare.AppDelegate", category: "AppDelegate")

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {

    // MARK: Internal

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        logger.info("App launched with options: \(launchOptions.debugDescription)")

        UNUserNotificationCenter.current().delegate = self

        return true
    }

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }

    // MARK: Private

    private var foregroundRefreshTask: Task<Void, Never>?
    private let tokenValidity: TimeInterval = 60 * 60
    private let safetyBuffer: TimeInterval = 5 * 60

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
