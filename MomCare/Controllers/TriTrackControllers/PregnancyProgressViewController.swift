//
//  PregnancyProgressViewController.swift
//  MomCare
//
//  Created by RITIK RANJAN on 14/06/25.
//

import UIKit
import SwiftUI

class PregnancyProgressViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let trimesterData = TriTrackData.getTrimesterData(for: MomCareUser.shared.user?.pregancyData?.week ?? 1)
        let pregnancyData = MomCareUser.shared.user?.pregancyData

        guard let trimesterData, let pregnancyData else {
            return
        }

        let pregnancyProgressView = PregnancyProgressView(trimesterData: trimesterData, pregnancyData: pregnancyData)
        let hostingController = UIHostingController(rootView: pregnancyProgressView)

        // Add the hosting controller as a child
        addChild(hostingController)
        view.addSubview(hostingController.view)

        // Set up constraints
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hostingController.didMove(toParent: self)
    }
}
