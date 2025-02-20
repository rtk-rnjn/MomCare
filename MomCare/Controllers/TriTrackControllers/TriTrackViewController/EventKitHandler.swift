//
//  EventKitHandler.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/02/25.
//

import Foundation
import UIKit
import EventKit
import EventKitUI

extension TriTrackViewController: EKEventEditViewDelegate, EKEventViewDelegate {
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

    func presentEKEventEditViewController(with event: EKEvent?) {
        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.eventStore = TriTrackViewController.eventStore
        eventEditViewController.event = .none

        eventEditViewController.editViewDelegate = self

        present(eventEditViewController, animated: true, completion: nil)
    }

    func presentEKEventViewController(with event: EKEvent) {
        let eventViewController = EKEventViewController()
        eventViewController.event = event
        eventViewController.allowsEditing = true
        eventViewController.allowsCalendarPreview = true

        let navigationController = UINavigationController(rootViewController: eventViewController)
        eventViewController.delegate = self

        present(navigationController, animated: true)
    }

    @objc func dismissEventViewController() {
        dismiss(animated: true, completion: nil)
    }

    // https://stackoverflow.com/a/44415132
    // https://stackoverflow.com/a/50369804

    func requestAccessForCalendar() {
        let status = EKEventStore.authorizationStatus(for: .event)

        switch status {
        case .denied, .restricted, .notDetermined:
            TriTrackViewController.eventStore.requestFullAccessToEvents { success, _ in
                TriTrackViewController.eventStore = .init()
                if success {
                    TriTrackViewController.eventStore = EKEventStore()
                    DispatchQueue.main.async {
                        _ = self.createOrGetEvent()
                    }
                }
            }

        case .authorized:
            break
        default:
            break
        }
    }

    func requestAccessForReminders() {
        let status = EKEventStore.authorizationStatus(for: .reminder)

        switch status {
        case .denied, .restricted, .notDetermined:
            TriTrackViewController.eventStore.requestFullAccessToReminders { success, _ in
                TriTrackViewController.eventStore = .init()
                if success {
                    TriTrackViewController.eventStore = EKEventStore()
                    DispatchQueue.main.async {
                        _ = self.createOrGetReminder()
                    }
                }
            }

        case .authorized:
            break
        default:
            break
        }
    }

    private func createOrGetCalendar(identifierKey: String, eventType: EKEntityType, title: String, defaultCalendar: EKCalendar?) -> EKCalendar? {
        let identifier: String? = Utils.get(fromKey: identifierKey)
        if let identifier {
            return TriTrackViewController.eventStore.calendar(withIdentifier: identifier)
        }

        let newCalendar = EKCalendar(for: eventType, eventStore: TriTrackViewController.eventStore)
        newCalendar.title = title
        if let localSource = TriTrackViewController.eventStore.sources.first(where: { $0.sourceType == .local }) {
            newCalendar.source = localSource
        } else {
            newCalendar.source = defaultCalendar?.source
        }

        UserDefaults.standard.set(newCalendar.calendarIdentifier, forKey: identifierKey)

        try? TriTrackViewController.eventStore.saveCalendar(newCalendar, commit: true)

        return newCalendar
    }

    func createOrGetEvent() -> EKCalendar? {
        return createOrGetCalendar(identifierKey: "TriTrackEvent", eventType: .event, title: "MomCare - TriTrack Calendar", defaultCalendar: TriTrackViewController.eventStore.defaultCalendarForNewEvents)
    }

    func createOrGetReminder() -> EKCalendar? {
        return createOrGetCalendar(identifierKey: "TriTrackReminder", eventType: .reminder, title: "MomCare - TriTrack Reminders", defaultCalendar: TriTrackViewController.eventStore.defaultCalendarForNewReminders())
    }
}
