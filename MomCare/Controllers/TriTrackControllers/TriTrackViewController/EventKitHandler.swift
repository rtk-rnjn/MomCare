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
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        switch action {
        case .saved:
            if let event = controller.event {
                presentEKEventViewController(event: event)
            }

        case .canceled, .deleted:
            dismiss(animated: true, completion: nil)
        @unknown default:
            break
        }
    }

    func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {}

    func presentEKEventEditViewController(event: EKEvent?) {
        let eventStore = EKEventStore()

        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.eventStore = eventStore
        eventEditViewController.event = event

        eventEditViewController.editViewDelegate = self

        present(eventEditViewController, animated: true, completion: nil)
    }

    func presentEKEventViewController(event: EKEvent) {
        let eventViewController = EKEventViewController()
        eventViewController.delegate = self
        eventViewController.event = event
        eventViewController.allowsEditing = true

        present(eventViewController, animated: true, completion: nil)
    }

    // https://stackoverflow.com/a/44415132
    // https://stackoverflow.com/a/50369804

    func requestAccessToCalendar() {
        let status = EKEventStore.authorizationStatus(for: .event)

        switch status {
        case .denied, .restricted, .notDetermined:
            eventStore.requestFullAccessToEvents { success, _ in
                self.eventStore = EKEventStore()

                if success {
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

    func requestAccessToReminders() {
        let status = EKEventStore.authorizationStatus(for: .reminder)

        switch status {
        case .denied, .restricted, .notDetermined:
            eventStore.requestFullAccessToReminders { success, _ in
                self.eventStore = EKEventStore()

                if success {
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
        eventStore = EKEventStore()

        if let identifier = UserDefaults.standard.string(forKey: identifierKey) {
            return eventStore.calendar(withIdentifier: identifier)
        }

        let newCalendar = EKCalendar(for: eventType, eventStore: eventStore)
        newCalendar.title = title
        if let localSource = eventStore.sources.filter({ $0.sourceType == .local }).first {
            newCalendar.source = localSource
        } else {
            newCalendar.source = defaultCalendar?.source
        }

        UserDefaults.standard.set(newCalendar.calendarIdentifier, forKey: identifierKey)

        try? eventStore.saveCalendar(newCalendar, commit: true)

        return newCalendar
    }

    func createOrGetEvent() -> EKCalendar? {
        return createOrGetCalendar(identifierKey: "TriTrackEvent", eventType: .event, title: "MomCare - TriTrack Calendar", defaultCalendar: eventStore.defaultCalendarForNewEvents)
    }

    func createOrGetReminder() -> EKCalendar? {
        return createOrGetCalendar(identifierKey: "TriTrackReminder", eventType: .reminder, title: "MomCare - TriTrack Reminders", defaultCalendar: eventStore.defaultCalendarForNewReminders())
    }
}
