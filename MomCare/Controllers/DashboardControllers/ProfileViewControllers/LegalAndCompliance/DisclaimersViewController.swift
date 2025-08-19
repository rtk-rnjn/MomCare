import SwiftUI
import UIKit

class DisclaimersViewController: UIHostingController<DisclaimersView> {

    init() {
        super.init(rootView: DisclaimersView())
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: DisclaimersView())
    }
}
