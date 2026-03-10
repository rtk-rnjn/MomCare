import BackgroundTasks
import SwiftUI
import Combine
import OSLog
import UIKit
import UserNotifications
import WatchConnectivity

private let refreshTokenBackgroundTaskIdentifier = "com.MomCare.BackgroundTask.RefreshToken"
private let logger: Logger = .init(subsystem: "com.MomCare.AppDelegate", category: "AppDelegate")

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        logger.info("App launched with options: \(launchOptions.debugDescription)")
        UIApplication.shared.registerForRemoteNotifications()

        _ = MetricKitManager.shared
        _ = WatchConnector.shared

        UNUserNotificationCenter.current().delegate = self

        UISegmentedControl.appearance().selectedSegmentTintColor = .white
        UISegmentedControl.appearance().backgroundColor = UIColor(Color.CustomColors.mutedRaspberry)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.CustomColors.mutedRaspberry)], for: .selected)

        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.black
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.3)

        return true
    }

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { unsafe String(format: "%02.2hhx", $0) }.joined()
        guard let data = RegisterDevice(deviceToken: token).encodeUsingJSONEncoder() else {
            return
        }
        Task {
            if let authenticationHeaders = AuthenticationService.authorizationHeaders {
                let _: NetworkResponse<Bool>? = try? await NetworkManager.shared.post(url: Endpoint.apns.urlString, body: data, headers: authenticationHeaders)
            }
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        logger.error("Failed to register for remote notifications: \(error.localizedDescription)")
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
