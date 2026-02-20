import Combine
import OSLog
import SwiftUI

private let logger: Logger = .init(subsystem: "com.MomCare.SceneDelegate", category: "SceneDelegate")

class SceneDelegate: UIResponder, UIWindowSceneDelegate, ObservableObject {
    func sceneWillEnterForeground(_: UIScene) {
        logger.info("Scene will enter foreground")
    }

    func sceneDidBecomeActive(_: UIScene) {
        logger.info("Scene did become active")
    }

    func sceneWillResignActive(_: UIScene) {
        logger.info("Scene will resign active")
    }
}
