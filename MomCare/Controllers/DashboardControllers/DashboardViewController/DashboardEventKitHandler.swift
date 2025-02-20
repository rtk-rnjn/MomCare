//
//  DashboardEventKitHandler.swift
//  MomCare
//
//  Created by Ritik Ranjan on 20/02/25.
//

import Foundation
import EventKit
import EventKitUI

extension DashboardViewController: EKEventEditViewDelegate {
    nonisolated func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        switch action {
        case .saved:
            break
        case .canceled, .deleted:
            DispatchQueue.main.async {
                controller.dismiss(animated: true)
            }

        @unknown default:
            break
        }
    }

    func presentEKEventEditViewController(with event: EKEvent?) {
        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.eventStore = TriTrackViewController.eventStore
        eventEditViewController.event = .none

        eventEditViewController.editViewDelegate = self

        present(eventEditViewController, animated: true, completion: nil)
    }
}
