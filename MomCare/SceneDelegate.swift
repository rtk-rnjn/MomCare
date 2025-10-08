//
//  SceneDelegate.swift
//  MomCare
//
//  Created by Ritik Ranjan on 10/01/25.
//

import UIKit
import OSLog

private let logger: Logger = .init(subsystem: "com.MomCare.SceneDelegate", category: "SceneDelegate")

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var launchedShortcutItem: UIApplicationShortcutItem?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        logger.debug("Scene will connect: \(String(describing: scene))")
        guard let scene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: scene)
        let userSignedUp = MomCareUser.shared.isUserSignedUp()
        let storyboard = userSignedUp ? UIStoryboard(name: "InitialStoryboard", bundle: nil) : UIStoryboard(name: "Main", bundle: nil)

        let initialViewController = storyboard.instantiateInitialViewController()

        window.rootViewController = initialViewController
        self.window = window
        window.makeKeyAndVisible()

        _ = WatchConnector.shared
        _ = MomCareUser.shared

        logger.info("Scene connected with rootViewController: \(String(describing: initialViewController))")

        launchedShortcutItem = connectionOptions.shortcutItem
    }

    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {

        let success = AppShortcuts.shared.performAction(for: shortcutItem, in: window)
        completionHandler(success)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        logger.debug("Scene did disconnect")
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        logger.debug("Scene did become active")
        UIApplication.shared.shortcutItems = AppShortcuts.shared.items

        if let launchedShortcutItem {
            AppShortcuts.shared.performAction(for: launchedShortcutItem, in: window)
            self.launchedShortcutItem = nil
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        logger.debug("Scene will resign active")
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        logger.debug("Scene will enter foreground")
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        logger.debug("Scene did enter background")
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
