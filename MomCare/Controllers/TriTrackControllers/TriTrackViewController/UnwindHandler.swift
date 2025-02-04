//
//  UnwindHandler.swift
//  MomCare
//
//  Created by Ritik Ranjan on 24/01/25.
//

import UIKit
import EventKit

extension TriTrackViewController {
    @IBAction func unwinToTriTrack(_ sender: UIStoryboardSegue) {
        guard let sourceVC = sender.source as? TriTrackAddEventViewController else { return }

        switch sender.identifier {
        case "unwindToTriTrackViaDone":
            handleDoneButtonTapped(with: sourceVC)
        case "unwindToTriTrackViaCancel":
            break
        default:
            fatalError("love is a battlefield")
        }
    }

    private func handleDoneButtonTapped(with viewController: TriTrackAddEventViewController) {

        switch viewController.viewControllerValue {
        case .eventsReminderView:
            handleDoneButtonTappedForEventsReminders(with: viewController)
        case .symptomsView:
            handleDoneButtonTappedForSymptomsView(with: viewController)
        case .none:
            fatalError("what is love?")
        }
    }

    private func handleDoneButtonTappedForEventsReminders(with viewController: TriTrackAddEventViewController) {
        switch TriTrackEventReminderViewControlSegmentValue(rawValue: viewController.eventReminderSegmentControl.selectedSegmentIndex) {
        case .eventView:
            handleDoneButtonTappedForEventsView(with: viewController)
        case .reminderView:
            handleDoneButtonTappedForRemindersView(with: viewController)
        default:
            fatalError("Love is not what you think it is")
        }
    }

    private func handleDoneButtonTappedForSymptomsView(with viewController: TriTrackAddEventViewController) {
        let title = viewController.addSymptomsTableViewController?.titleField.text
        let notes = viewController.addSymptomsTableViewController?.notesField.text
        let dateTime = viewController.addSymptomsTableViewController?.dateTime.date

        guard let title, let dateTime else { return }

        // TODO: 
        symptomsViewController?.symptomsTableViewController?.refreshData()
    }

    private func handleDoneButtonTappedForEventsView(with viewController: TriTrackAddEventViewController) {
        let title = viewController.addEventTableViewController?.titleField.text
        let location = viewController.addEventTableViewController?.locationField.text

        let startDateTime = viewController.addEventTableViewController?.startDateTimePicker.date
        let endDateTime = viewController.addEventTableViewController?.endDateTimePicker.date

        let repeatAfter = viewController.addEventTableViewController?.selectedRepeatOption
        let travelTime = viewController.addEventTableViewController?.selectedTravelTimeOption
        let alertTime = viewController.addEventTableViewController?.selectedAlertTimeOption

        let allDay = viewController.addEventTableViewController?.allDaySwitch.isOn ?? false

        guard let title, let startDateTime else { return }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDateTime

        event.location = location
        event.isAllDay = allDay
        if let repeatAfter = repeatAfter {
            event.recurrenceRules = createRecurrenceRule(for: repeatAfter)
        }
        if let alertTime = alertTime {
            event.addAlarm(EKAlarm(relativeOffset: -alertTime))
        }
        if let travelTime = travelTime {
            if let endDateTime = endDateTime?.addingTimeInterval(travelTime) {
                event.endDate = endDateTime
            }
        }
        event.calendar = createOrGetEvent()

        try? eventStore.save(event, span: .thisEvent)

        eventsViewController?.appointmentsTableViewController?.refreshData()
    }

    private func handleDoneButtonTappedForRemindersView(with viewController: TriTrackAddEventViewController) {
        let title = viewController.addReminderTableViewController?.titleField.text
        let notes = viewController.addReminderTableViewController?.notesField.text
        let dueDate = viewController.addReminderTableViewController?.dateTime.date
        let repeatAfter = viewController.addReminderTableViewController?.selectedRepeatOption

        guard let title, let notes, let dueDate else { return }

        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.notes = notes
        
        let dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        reminder.dueDateComponents = dueDateComponents
        reminder.calendar = createOrGetReminder()
        reminder.recurrenceRules = createRecurrenceRule(for: repeatAfter)

        try? eventStore.save(reminder, commit: true)
        eventsViewController?.remindersTableViewController?.refreshData()
    }
    
    private func createRecurrenceRule(for interval: TimeInterval?) -> [EKRecurrenceRule] {
        guard let interval = interval, interval > 0 else { return [] }
        
        var recurrenceFrequency: EKRecurrenceFrequency = .daily
        var intervalValue: Int = 1
        
        switch interval {
        case 24 * 60 * 60:
            recurrenceFrequency = .daily
            intervalValue = 1
        case 24 * 60 * 60 * 7:
            recurrenceFrequency = .weekly
            intervalValue = 1
        case 24 * 60 * 60 * 7 * 2:
            recurrenceFrequency = .weekly
            intervalValue = 2
        case 24 * 60 * 60 * 7 * 30:
            recurrenceFrequency = .monthly
            intervalValue = 1
        case 24 * 60 * 60 * 7 * 30 * 12:
            recurrenceFrequency = .yearly
            intervalValue = 1
        default:
            return []
        }
        
        let rule = EKRecurrenceRule(
            recurrenceWith: recurrenceFrequency,
            interval: intervalValue,
            end: nil
        )

        return [rule]
    }
}
