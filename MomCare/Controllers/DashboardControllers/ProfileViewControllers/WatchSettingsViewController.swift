import UIKit
import SwiftUI

class WatchSettingsViewController: UIHostingController<WatchSettingsView> {

    init() {
        super.init(rootView: WatchSettingsView())
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: WatchSettingsView())
    }
}
