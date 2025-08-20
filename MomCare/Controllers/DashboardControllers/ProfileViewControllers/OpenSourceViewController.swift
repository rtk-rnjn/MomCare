import UIKit
import SwiftUI

class OpenSourceViewController: UIHostingController<OpenSourceView> {

    init() {
        super.init(rootView: OpenSourceView())
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: OpenSourceView())
    }
}
