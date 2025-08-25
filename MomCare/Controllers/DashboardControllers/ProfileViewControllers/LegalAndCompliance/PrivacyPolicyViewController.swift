//
//  PrivacyPolicyViewController.swift
//  MomCare
//
//  Created by Nupur on 25/08/25.
//

import UIKit
import SwiftUI

class PrivacyPolicyViewController: UIHostingController<PrivacyPolicyView> {
    init() {
        super.init(rootView: PrivacyPolicyView())
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: PrivacyPolicyView())
    }
}
