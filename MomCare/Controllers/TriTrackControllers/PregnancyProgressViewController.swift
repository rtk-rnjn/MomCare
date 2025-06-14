//
//  PregnancyProgressViewController.swift
//  MomCare
//
//  Created by RITIK RANJAN on 14/06/25.
//

import SwiftUI

class PregnancyProgressViewController: UIHostingController<PregnancyProgressView> {
    required init?(coder: NSCoder) {
        let view = PregnancyProgressView()
        if let view {
            super.init(coder: coder, rootView: view)
        } else {
            fatalError("PregnancyProgressView is nil")
        }
    }
}
