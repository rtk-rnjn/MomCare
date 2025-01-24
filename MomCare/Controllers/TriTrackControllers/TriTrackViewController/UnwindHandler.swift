//
//  UnwindHandler.swift
//  MomCare
//
//  Created by Ritik Ranjan on 24/01/25.
//

import UIKit

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

        guard let title = title, let dateTime = dateTime else { return }

        let triTrackSymptom = TriTrackSymptom(title: title, notes: notes, atTime: dateTime)
        MomCareUser.shared.addSymptom(triTrackSymptom)
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

        guard let title = title, let startDateTime = startDateTime else { return }

        let triTrackEvent = TriTrackEvent(title: title, location: location, allDay: allDay, startDate: startDateTime, endDate: endDateTime, travelTime: travelTime, alertBefore: alertTime, repeatAfter: repeatAfter)

        MomCareUser.shared.addEvent(triTrackEvent)
        eventsViewController?.appointmentsTableViewController?.refreshData()
    }

    private func handleDoneButtonTappedForRemindersView(with viewController: TriTrackAddEventViewController) {
        let title = viewController.addReminderTableViewController?.titleField.text
        let notes = viewController.addReminderTableViewController?.notesField.text
        let dateTime = viewController.addReminderTableViewController?.dateTime.date
        let timeInterval = viewController.addReminderTableViewController?.selectedRepeatOption

        guard let title = title, let notes = notes, let dateTime = dateTime else { return }

        let triTrackReminder = TriTrackReminder(title: title, date: dateTime, notes: notes, repeatAfter: timeInterval)
        MomCareUser.shared.addReminder(triTrackReminder)
        eventsViewController?.remindersTableViewController?.refreshData()
    }
}
