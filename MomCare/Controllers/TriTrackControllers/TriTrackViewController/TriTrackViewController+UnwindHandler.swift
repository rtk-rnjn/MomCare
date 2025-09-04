//

//  TriTrackViewController+UnwindHandler.swift

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

        guard let title = viewController.addSymptomsTableViewController?.titleField.text, let dateTime = viewController.addSymptomsTableViewController?.dateTime.date else { return }

        Task {

            await EventKitHandler.shared.createEvent(title: title, startDate: dateTime, endDate: dateTime, notes: "Symptom event")

            DispatchQueue.main.async {

                self.symptomsViewController?.symptomsTableViewController?.refreshData()

            }

        }

    }

    private func handleEventsView(with viewController: TriTrackAddEventViewController) {

        guard let eventTVC = viewController.addEventTableViewController, let title = eventTVC.titleField.text else { return }

        let recurrenceRules = eventTVC.selectedRepeatOption.map { TriTrackViewController.createRecurrenceRule(for: $0) }

        let alarm = eventTVC.selectedAlertTimeOption.map { EKAlarm(relativeOffset: -$0) }

        let startDate = eventTVC.startDateTimePicker.date

        let endDate = eventTVC.allDaySwitch.isOn ? startDate : eventTVC.endDateTimePicker.date.addingTimeInterval(eventTVC.selectedTravelTimeOption ?? 0)

        Task {

            await EventKitHandler.shared.createEvent(

                title: title, startDate: startDate, endDate: endDate, isAllDay: eventTVC.allDaySwitch.isOn, notes: nil, recurrenceRules: recurrenceRules, location: eventTVC.locationField.text, alarm: alarm

            )

            DispatchQueue.main.async {

                self.eventsViewController?.appointmentsTableViewController?.refreshData()

            }

        }

    }

    private func handleRemindersView(with viewController: TriTrackAddEventViewController) {

        guard let reminderTVC = viewController.addReminderTableViewController, let title = reminderTVC.titleField.text else { return }

        let dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: reminderTVC.dateTime.date)

        let recurrenceRules = TriTrackViewController.createRecurrenceRule(for: reminderTVC.selectedRepeatOption)

        Task {

            await EventKitHandler.shared.createReminder(title: title, notes: reminderTVC.notesField.text, dueDateComponents: dueDateComponents, recurrenceRules: recurrenceRules)

            DispatchQueue.main.async {

                self.eventsViewController?.remindersTableViewController?.refreshData()

            }

        }

    }

    static func createRecurrenceRule(for interval: TimeInterval?) -> [EKRecurrenceRule] {

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
