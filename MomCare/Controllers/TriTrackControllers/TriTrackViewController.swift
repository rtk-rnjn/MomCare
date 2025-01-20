//
//  TriTrackViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 16/01/25.
//

import UIKit

enum ContainerType {
    case meAndBaby
    case events
    case symptoms
}

class TriTrackViewController: UIViewController {
    @IBOutlet var triTrackInternalView: UIView!

    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var triTrackSegmentedControl: UISegmentedControl!

    @IBOutlet var meAndBabyContainerView: UIView!
    @IBOutlet var eventsContainerView: UIView!
    @IBOutlet var symptomsContainerView: UIView!

    var currentSegmentIndex: Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        triTrackInternalView.backgroundColor = .white
        triTrackInternalView.layer.cornerRadius = 15
        
        prepareSegmentedControl()
        updateView()
    }
    
    func hideAllContainers(except: ContainerType) {
        let allContainers: [ContainerType: UIView] = [
            .meAndBaby: meAndBabyContainerView,
            .events: eventsContainerView,
            .symptoms: symptomsContainerView
        ]
        
        allContainers.values.forEach { $0.isHidden = true }
        
        if let container = allContainers[except] {
            container.isHidden = false
        }
    }

    func prepareSegmentedControl() {
        triTrackSegmentedControl.selectedSegmentIndex = currentSegmentIndex

        let normalTextAttribute: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white
        ]
        
        let selectedBackground = Converters.convertHexToUIColor(hex: "924350")

        let selectedTextAttribute: [NSAttributedString.Key: Any] = [
            .foregroundColor: selectedBackground
        ]

        triTrackSegmentedControl.setTitleTextAttributes(normalTextAttribute, for: .normal)
        triTrackSegmentedControl.setTitleTextAttributes(selectedTextAttribute, for: .selected)
    }
    
    func updateView() {
        currentSegmentIndex = triTrackSegmentedControl.selectedSegmentIndex

        switch currentSegmentIndex {
        case 0:
            addButton.isEnabled = false
            hideAllContainers(except: .meAndBaby)
        case 1:
            addButton.isEnabled = true
            hideAllContainers(except: .events)
        case 2:
            addButton.isEnabled = true
            hideAllContainers(except: .symptoms)
        default:
            // Should never happen
            fatalError("love is beautiful thing")
        }
    }

    @IBAction func segmentTapped(_ sender: UISegmentedControl) {
        updateView()
    }
    
    @IBAction func unwinToTriTrack(_ sender: UIStoryboardSegue) {
        guard let sourceVC = sender.source as? TriTrackAddEventViewController else { return }

        sourceVC.reloadAllTableViews()
        
        switch sender.identifier {
        case "unwindToTriTrackViaDone":
            handleDoneButtonTapped(with: sourceVC)
        case "unwindToTriTrackViaCancel":
            break
        default:
            fatalError("love is a battlefield")
        }
    }

    func handleDoneButtonTapped(with viewController: UIViewController) {
        guard let viewController = viewController as? TriTrackAddEventViewController else { return }
        
        switch viewController.viewControllerValue {
        case .eventsReminderView:
            handleDoneButtonTappedForEventsReminders(with: viewController)
        case .symptomsView:
            handleDoneButtonTappedForSymptomsView(with: viewController)
        case .none:
            fatalError("what is love?")
        }
    }
    
    func handleDoneButtonTappedForEventsReminders(with viewController: TriTrackAddEventViewController) {
        switch TriTrackEventReminderViewControlSegmentValue(rawValue: viewController.eventReminderSegmentControl.selectedSegmentIndex) {
        case .eventView:
            handleDoneButtonTappedForEventsView(with: viewController)
        case .reminderView:
            handleDoneButtonTappedForRemindersView(with: viewController)
        default:
            fatalError("Love is not what you think it is")
        }
    }
    
    // MARK: - Handlers for done button tapped

    func handleDoneButtonTappedForSymptomsView(with viewController: TriTrackAddEventViewController) {
        let title = viewController.addSymptomsTableViewController?.titleField.text
        let notes = viewController.addSymptomsTableViewController?.notesField.text
        let dateTime = viewController.addSymptomsTableViewController?.dateTime.date
        
        guard let title = title, let dateTime = dateTime else { return }
        
        let triTrackSymptom = TriTrackSymptom(title: title, notes: notes, atTime: dateTime)
        MomCareUser.shared.addSymptom(triTrackSymptom)
    }
    
    func handleDoneButtonTappedForEventsView(with viewController: TriTrackAddEventViewController) {
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
    }
    
    func handleDoneButtonTappedForRemindersView(with viewController: TriTrackAddEventViewController) {
        let title = viewController.addReminderTableViewController?.titleField.text
        let notes = viewController.addReminderTableViewController?.notesField.text
        let dateTime = viewController.addReminderTableViewController?.dateTime.date
        let timeInterval = viewController.addReminderTableViewController?.selectedRepeatOption

        guard let title = title, let notes = notes, let dateTime = dateTime else { return }
        
        let triTrackReminder = TriTrackReminder(title: title, date: dateTime, notes: notes, repeatAfter: timeInterval)
        MomCareUser.shared.addReminder(triTrackReminder)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "segueTriTrack" {
            if let destinationVC = segue.destination as? UINavigationController {
                let destinationVCTopController = destinationVC.topViewController as! TriTrackAddEventViewController
                destinationVCTopController.viewControllerValue = TriTrackViewControlSegmentValue(rawValue: triTrackSegmentedControl.selectedSegmentIndex)
            }
        }
    }
}
