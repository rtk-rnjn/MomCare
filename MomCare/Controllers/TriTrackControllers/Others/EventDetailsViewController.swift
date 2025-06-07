//
//  EventDetailsViewController.swift
//  MomCare
//
//  Created by RITIK RANJAN on 08/06/25.
//

import SwiftUI
import UIKit
import EventKit

class EventDetailsViewController: UIHostingController<EventDetailsView> {

    // MARK: Lifecycle

    init(event: EKEvent) {
        super.init(rootView: EventDetailsView(event: event))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = view.intrinsicContentSize
    }
}
