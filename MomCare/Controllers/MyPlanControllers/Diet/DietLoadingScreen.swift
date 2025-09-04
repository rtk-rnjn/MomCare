//
//  DietLoadingScreen.swift
//  MomCare
//
//  Created by RITIK RANJAN on 06/06/25.
//

import SwiftUI

class DietLoadingScreen: UIHostingController<DietPlanLoadingScreen> {
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: DietPlanLoadingScreen())
    }
}
