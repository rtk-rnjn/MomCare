// Source - https://stackoverflow.com/a/76728094
// Posted by eastriver lee
// Retrieved 2026-03-12, License - CC BY-SA 4.0

import UIKit

extension UIWindow {
    static var current: UIWindow {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows where window.isKeyWindow {
                return window
            }
        }
        fatalError()
    }
}

extension UIScreen {
    static var current: UIScreen {
        UIWindow.current.screen
    }
}
