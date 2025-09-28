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

    // MARK: Internal

    var window: UIWindow?

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

        logger.info("Scene connected with rootViewController: \(String(describing: initialViewController))")

        if let shortcutItem = connectionOptions.shortcutItem {
                    logger.info("Application launched via shortcut: \(shortcutItem.type)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.handleShortcut(item: shortcutItem)
                    }
        }
    }

    @discardableResult
        func handleShortcut(item: UIApplicationShortcutItem) -> Bool {
            logger.debug("Handling shortcut of type: \(item.type)")
            var success = false

            switch item.type {
            case "com.MomCare.LogSymptom":
                navigateToLogSymptom()
                success = true

            case "com.MomCare.AddAppointment":
                navigateToAddAppointment()
                success = true

            default:
                break
            }

            return success
        }

    func sceneDidDisconnect(_ scene: UIScene) {
        logger.debug("Scene did disconnect: \(String(describing: scene))")
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        logger.debug("Scene did become active: \(String(describing: scene))")
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        logger.debug("Scene will resign active: \(String(describing: scene))")
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        logger.debug("Scene will enter foreground: \(String(describing: scene))")
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        logger.debug("Scene did enter background: \(String(describing: scene))")
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    // MARK: Private

    private func navigateToTriTrackSegment(segmentIndex: Int) {
        guard let tabBarController = window?.rootViewController as? UITabBarController else {
                    return
        }
        tabBarController.selectedIndex = 2

        guard let navigationController = tabBarController.selectedViewController as? UINavigationController,
                      let triTrackVC = navigationController.topViewController as? TriTrackViewController else {
                    return
        }

        _ = triTrackVC.view
        triTrackVC.updateView(with: segmentIndex)
        triTrackVC.performSegue(withIdentifier: "segueShowTriTrackAddEventViewController", sender: nil)
    }

    private func navigateToLogSymptom() {
        navigateToTriTrackSegment(segmentIndex: 2)
    }

    private func navigateToAddAppointment() {
        navigateToTriTrackSegment(segmentIndex: 1)
    }

}
