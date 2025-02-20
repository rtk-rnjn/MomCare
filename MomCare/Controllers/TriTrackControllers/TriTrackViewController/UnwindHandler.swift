//
//  UnwindHandler.swift
//  MomCare
//
//  Created by Ritik Ranjan on 24/01/25.
//

import UIKit
import EventKit
import UserNotifications

extension TriTrackViewController {
    @IBAction func unwinToTriTrack(_ sender: UIStoryboardSegue) {
        guard let sourceVC = sender.source as? TriTrackAddEventViewController else { return }

        switch sender.identifier {
        case "unwindToTriTrackViaDone":
            handleDoneButtonTapped(with: sourceVC)
        case "unwindToTriTrackViaCancel":
            break
        default:
            fatalError("Invalid unwind segue identifier")
        }
    }

    private func handleDoneButtonTapped(with viewController: TriTrackAddEventViewController) {
        switch viewController.viewControllerValue {
        case .eventsReminderView:
            handleEventsReminders(with: viewController)
        case .symptomsView:
            handleSymptomsView(with: viewController)
        case .none:
            fatalError("Unexpected nil viewControllerValue")
        }
    }

    private func handleEventsReminders(with viewController: TriTrackAddEventViewController) {
        guard let segmentValue = TriTrackEventReminderViewControlSegmentValue(rawValue: viewController.eventReminderSegmentControl.selectedSegmentIndex) else {
            fatalError("Invalid segment index")
        }

        switch segmentValue {
        case .eventView:
            handleEventsView(with: viewController)
        case .reminderView:
            handleRemindersView(with: viewController)
        }
    }

    private func handleSymptomsView(with viewController: TriTrackAddEventViewController) {
        guard let title = viewController.addSymptomsTableViewController?.titleField.text,
              let dateTime = viewController.addSymptomsTableViewController?.dateTime.date else { return }

        let event = EKEvent(eventStore: TriTrackViewController.eventStore)
        event.title = title
        event.startDate = dateTime
        event.calendar = createOrGetEvent()

        symptomsViewController?.symptomsTableViewController?.refreshData()
    }

    private func handleEventsView(with viewController: TriTrackAddEventViewController) {
        guard let eventTVC = viewController.addEventTableViewController,
              let title = eventTVC.titleField.text else { return }

        let event = EKEvent(eventStore: TriTrackViewController.eventStore)
        event.title = title
        event.location = ((eventTVC.locationField.text?.isEmpty) != nil) ? eventTVC.locationField.text : nil
        event.startDate = eventTVC.startDateTimePicker.date
        event.isAllDay = eventTVC.allDaySwitch.isOn

        if let repeatAfter = eventTVC.selectedRepeatOption {
            event.recurrenceRules = createRecurrenceRule(for: repeatAfter)
        }
        if let alertTime = eventTVC.selectedAlertTimeOption {
            event.addAlarm(EKAlarm(relativeOffset: -alertTime))
        }
        event.endDate = eventTVC.allDaySwitch.isOn ? event.startDate : eventTVC.endDateTimePicker.date.addingTimeInterval(eventTVC.selectedTravelTimeOption ?? 0)
        event.calendar = createOrGetEvent()

        try? TriTrackViewController.eventStore.save(event, span: .thisEvent, commit: true)
        eventsViewController?.appointmentsTableViewController?.refreshData()
    }

    private func handleRemindersView(with viewController: TriTrackAddEventViewController) {
        guard let reminderTVC = viewController.addReminderTableViewController,
              let title = reminderTVC.titleField.text else { return }

        let reminder = EKReminder(eventStore: TriTrackViewController.eventStore)
        reminder.title = title
        reminder.notes = reminderTVC.notesField.text
        reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderTVC.dateTime.date)
        reminder.calendar = createOrGetReminder()
        reminder.recurrenceRules = createRecurrenceRule(for: reminderTVC.selectedRepeatOption)

        Utils.createNotification(title: reminder.title, body: reminder.notes, date: reminder.dueDateComponents?.date!)
        try? TriTrackViewController.eventStore.save(reminder, commit: true)
        eventsViewController?.remindersTableViewController?.refreshData()
    }

    private func createRecurrenceRule(for interval: TimeInterval?) -> [EKRecurrenceRule] {
        guard let interval, interval > 0 else { return [] }

        let (frequency, intervalValue): (EKRecurrenceFrequency, Int) = {
            switch interval {
            case 24 * 60 * 60: return (.daily, 1)
            case 24 * 60 * 60 * 7: return (.weekly, 1)
            case 24 * 60 * 60 * 7 * 2: return (.weekly, 2)
            case 24 * 60 * 60 * 30: return (.monthly, 1)
            case 24 * 60 * 60 * 365: return (.yearly, 1)
            default: return (.daily, 1)
            }
        }()

        return [EKRecurrenceRule(recurrenceWith: frequency, interval: intervalValue, end: nil)]
    }
}
