import UIKit

extension UIWindow {
#if os(iOS)
    static var current: UIWindow {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows where window.isKeyWindow {
                return window
            }
        }
        fatalError()
    }
#else
    static var currnt: UIWindow {
        UIApplication.shared.windows.first { $0.isKeyWindow }!
    }
#endif
}

extension UIScreen {
    static var current: UIScreen {
        UIWindow.current.screen
    }
}
