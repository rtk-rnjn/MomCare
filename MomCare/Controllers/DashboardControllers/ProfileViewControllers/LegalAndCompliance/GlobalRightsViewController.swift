//
//  GlobalRightsViewController.swift
//  MomCare
//
//  Created by Khushi Rana on 18/08/25.
//

import UIKit
import SwiftUI

class GlobalRightsViewController: UIHostingController<GlobalRightsView> {

    // MARK: Lifecycle

    init() {
        super.init(rootView: GlobalRightsView())
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: GlobalRightsView())
    }

}
