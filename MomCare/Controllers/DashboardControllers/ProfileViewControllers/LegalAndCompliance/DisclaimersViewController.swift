import SwiftUI
import UIKit

class DisclaimersViewController: UIHostingController<DisclaimersView> {

    // MARK: Lifecycle

    init() {
        super.init(rootView: DisclaimersView())
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: DisclaimersView())
    }
}
