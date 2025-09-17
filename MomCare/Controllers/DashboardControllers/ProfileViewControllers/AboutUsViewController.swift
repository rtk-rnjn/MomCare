import UIKit
import SwiftUI

class AboutUsViewController: UIHostingController<AboutUsView> {

    init() {
        super.init(rootView: AboutUsView())
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: AboutUsView())
    }
}
