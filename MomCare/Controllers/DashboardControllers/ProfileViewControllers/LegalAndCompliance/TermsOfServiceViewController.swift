//
//  TermsOfServiceViewController.swift
//  MomCare
//
//  Created by Khushi Rana on 17/08/25.
//

import UIKit
import SwiftUI

class TermsOfServiceViewController: UIHostingController<TermsOfServiceView> {
    // MARK: Lifecycle

    init() {
        super.init(rootView: TermsOfServiceView())
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: TermsOfServiceView())
    }
}
