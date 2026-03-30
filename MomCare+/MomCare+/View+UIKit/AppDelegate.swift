import BackgroundTasks
import Combine
import OSLog
import SwiftUI
import UIKit
import UserNotifications
import WidgetKit

private let refreshTaskIdentifier = "com.MomCare.BackgroundTask.RefreshToken"
private let logger: Logger = MomCareLogger.appDelegate

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        logger.info("App launched with options: \(launchOptions.debugDescription)")
        UNUserNotificationCenter.current().delegate = self

        WidgetCenter.shared.reloadAllTimelines()

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

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { unsafe String(format: "%02.2hhx", $0) }.joined()
        let data = try? RegisterDevice(deviceToken: token).encodeUsingJSONEncoder()

        Task {
            if let authenticationHeaders = MCAuthenticationService.authorizationHeaders {
                let _: NetworkResponse<Bool>? = try? await MCNetworkManager.shared.post(url: Endpoint.apns.urlString, body: data, headers: authenticationHeaders)
            }
        }
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        logger.error("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        print("Push received:", userInfo)
        return .newData
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}

extension AppDelegate {
    func registerBackgroundRefreshTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: refreshTaskIdentifier, using: .main) { task in
            if let task = task as? BGAppRefreshTask {
                self.scheduleBackgroundRefresh()
                Task {
                    await MCAuthenticationService.refresh(task: task)
                }
            }
        }
    }

    func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
            logger.info("Scheduled background refresh task")
        } catch {
            logger.error("Failed to schedule background refresh task: \(error.localizedDescription)")
        }
    }
}
