//
//  TriTrackViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 16/01/25.
//

import UIKit
import FSCalendar

enum TriTrackContainerViewType: Int {
    case meAndBabyContainerView = 0
    case eventsContainerView = 1
    case symptomsContainerView = 2
}

class TriTrackViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    @IBOutlet var triTrackInternalView: UIView!

    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var triTrackSegmentedControl: UISegmentedControl!

    @IBOutlet var meAndBabyContainerView: UIView!
    @IBOutlet var eventsContainerView: UIView!
    @IBOutlet var symptomsContainerView: UIView!

    @IBOutlet var calendarUIView: UIView!
    private var calendarView: FSCalendar!

    private var symptomsViewController: SymptomsViewController?
    private var eventsViewController: EventsViewController?

    private var currentSegmentIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView = FSCalendar(frame: CGRect(x: 0, y: 0, width: calendarUIView.frame.width, height: calendarUIView.frame.height + 150))
        calendarView.scope = .week
        calendarView.select(Date())

        calendarView.dataSource = self
        calendarView.delegate = self

        calendarUIView.addSubview(calendarView)
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("Date selected: \(date)")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        triTrackInternalView.backgroundColor = .white
        triTrackInternalView.layer.cornerRadius = 15

        prepareSegmentedControl()
        updateView()
    }

    private func hideAllContainers(except: TriTrackContainerViewType) {
        let allContainers: [TriTrackContainerViewType: UIView] = [
            .meAndBabyContainerView: meAndBabyContainerView,
            .eventsContainerView: eventsContainerView,
            .symptomsContainerView: symptomsContainerView
        ]

        allContainers.values.forEach { $0.isHidden = true }

        if let container = allContainers[except] {
            container.isHidden = false
        }
    }

    private func prepareSegmentedControl() {
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

    private func updateView() {
        currentSegmentIndex = triTrackSegmentedControl.selectedSegmentIndex

        switch currentSegmentIndex {
        case 0:
            addButton.isEnabled = false
            hideAllContainers(except: .meAndBabyContainerView)
        case 1:
            addButton.isEnabled = true
            hideAllContainers(except: .eventsContainerView)
        case 2:
            addButton.isEnabled = true
            hideAllContainers(except: .symptomsContainerView)
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

    // MARK: - Handlers for done button tapped

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier

        guard let identifier = identifier else { return }

        switch identifier {
        case "segueTriTrack":
            if let destinationVC = segue.destination as? UINavigationController {
                let destinationVCTopController = destinationVC.topViewController as! TriTrackAddEventViewController
                destinationVCTopController.viewControllerValue = TriTrackViewControlSegmentValue(rawValue: triTrackSegmentedControl.selectedSegmentIndex)
            }
        case "embedShowSymptomsViewController":
            if let destinationVC = segue.destination as? SymptomsViewController {
                symptomsViewController = destinationVC
            }
        case "embedShowEventsViewController":
            if let destinationVC = segue.destination as? EventsViewController {
                eventsViewController = destinationVC
            }
        default:
            break
        }
    }
}
