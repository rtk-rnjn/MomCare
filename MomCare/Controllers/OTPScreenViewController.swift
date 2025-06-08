//
//  OTPScreenViewController.swift
//  MomCare
//
//  Created by RITIK RANJAN on 08/06/25.
//

import SwiftUI

class OTPScreenViewController: UIHostingController<OTPScreen> {

    init() {
        super.init(rootView: OTPScreen())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
