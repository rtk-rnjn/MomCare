import UIKit

import SwiftUI

class CreditsViewController: UIHostingController<CreditsView> {

    init() {

        super.init(rootView: CreditsView())

    }

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder, rootView: CreditsView())

    }

}
