import SwiftUI

enum CornerRadius {
    // MARK: Internal

    static var outer: CGFloat {
        if #available(iOS 26, *) {
            Base.outer_iOS26
        } else {
            Base.outer_iOS17
        }
    }

    static var inner: CGFloat {
        if #available(iOS 26, *) {
            Base.inner_iOS26
        } else {
            Base.inner_iOS17
        }
    }

    static func inner(for outer: CGFloat) -> CGFloat {
        if #available(iOS 26, *) {
            max(outer - 4, 0)
        } else {
            max(outer - 4, 0)
        }
    }

    // MARK: Private

    private enum Base {
        static let outer_iOS17: CGFloat = 20
        static let inner_iOS17: CGFloat = 16

        static let outer_iOS26: CGFloat = 24
        static let inner_iOS26: CGFloat = 20
    }
}
