//
//  EventKitHandlerUI.swift
//  MomCare
//
//  Created by Aryan Singh on 17/09/25.
//

@preconcurrency import EventKit
import EventKitUI
import UIKit

@MainActor
class EventKitHandlerUIDelegate: NSObject, EKEventEditViewDelegate, EKEventViewDelegate {
    var viewController: UIViewController?

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

    nonisolated func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {
        switch action {
        case .done:
            DispatchQueue.main.async {
                controller.dismiss(animated: true)
            }

        default:
            break
        }
    }

    func presentEKEventEditViewController(with eventInfo: EventInfo?) async {
        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.eventStore = await EventKitHandler.shared.getEventStore()
        eventEditViewController.event = await EventKitHandler.shared.getEKEvent(from: eventInfo)
        eventEditViewController.editViewDelegate = self

        DispatchQueue.main.async {
            self.viewController?.present(eventEditViewController, animated: true, completion: nil)
        }
    }

    func presentEKEventViewController(with eventInfo: EventInfo?) async {
        let eventViewController = EKEventViewController()
        eventViewController.event = await EventKitHandler.shared.getEKEvent(from: eventInfo)
        eventViewController.allowsEditing = true
        eventViewController.allowsCalendarPreview = true

        let navigationController = UINavigationController(rootViewController: eventViewController)
        eventViewController.delegate = self

        viewController?.present(navigationController, animated: true)
    }

}
