//

//  EventDetailsViewController.swift

//  MomCare

//

//  Created by RITIK RANJAN on 08/06/25.

//

import SwiftUI

import UIKit

class EventDetailsViewController: UIHostingController<EventDetailsView> {

    // MARK: Lifecycle

    init(cell: UIView, eventGetter: (() async -> EventInfo?)? = nil) {

        self.eventGetter = eventGetter

        super.init(rootView: EventDetailsView(event: nil, cellWidth: max(cell.frame.width, UIScreen.main.bounds.width / 1.5)))

    }

    required init?(coder aDecoder: NSCoder) {

        fatalError("init(coder:) has not been implemented")

    }

    // MARK: Internal

    var eventGetter: (() async -> EventInfo?)?

    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        preferredContentSize = view.intrinsicContentSize

    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        Task {

            let eventFromEventGetter = await eventGetter?()

            if let event = eventFromEventGetter {

                await MainActor.run {

                    rootView.event = event

                }

                return

            }

            let event = await EventKitHandler.shared.fetchUpcomingAppointment()

            await MainActor.run {

                rootView.event = event

            }

        }

    }

}
