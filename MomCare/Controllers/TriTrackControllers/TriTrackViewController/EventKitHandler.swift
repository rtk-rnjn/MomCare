//
//  EventKitHandler.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/02/25.
//

import Foundation
import UIKit
import EventKit

extension TriTrackViewController {
    // https://stackoverflow.com/a/44415132
    // https://stackoverflow.com/a/50369804

    func requestAccessToCalendar() {
        let status = EKEventStore.authorizationStatus(for: .event)

        switch status {
        case .denied, .restricted, .notDetermined:
            eventStore.requestFullAccessToEvents(completion: { success, _ in
                self.eventStore = EKEventStore()

                if success {
                    DispatchQueue.main.async {
                        _ = self.createOrGetEvent()
                    }
                }
            })

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
            eventStore.requestFullAccessToReminders(completion: { success, _ in
                self.eventStore = EKEventStore()

                if success {
                    DispatchQueue.main.async {
                        _ = self.createOrGetReminder()
                    }
                }
            })

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
        return createOrGetCalendar(identifierKey: "TriTrackEvent", eventType: .event, title: "MomCare - TriTrack Reminders", defaultCalendar: eventStore.defaultCalendarForNewEvents)
    }

    func createOrGetReminder() -> EKCalendar? {
        return createOrGetCalendar(identifierKey: "TriTrackReminder", eventType: .reminder, title: "MomCare - TriTrack Reminders", defaultCalendar: eventStore.defaultCalendarForNewReminders())
    }
}
