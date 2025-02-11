//
//  TriTrackViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 16/01/25.
//

import UIKit
import FSCalendar
import EventKit

enum TriTrackContainerViewType: Int {
    case meAndBabyContainerView = 0
    case eventsContainerView = 1
    case symptomsContainerView = 2
}

class TriTrackViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {

    // MARK: Internal

    @IBOutlet var triTrackInternalView: UIView!

    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var refreshButton: UIBarButtonItem!
    @IBOutlet var triTrackSegmentedControl: UISegmentedControl!

    @IBOutlet var meAndBabyContainerView: UIView!
    @IBOutlet var eventsContainerView: UIView!
    @IBOutlet var symptomsContainerView: UIView!

    @IBOutlet var calendarUIView: UIView!

    var symptomsViewController: SymptomsViewController?
    var eventsViewController: EventsViewController?

    var currentSegmentValue: Int = 0
    var eventStore: EKEventStore = .init()

    var activityIndicator: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCalendar()

        requestAccessToCalendar()
        requestAccessToReminders()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        triTrackInternalView.backgroundColor = .white
        triTrackInternalView.layer.cornerRadius = 15

        prepareSegmentedControl()
        updateView(with: currentSegmentValue)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier

        guard let identifier else { return }

        switch identifier {
        case "segueShowTriTrackAddEventViewController":
            if let navController = segue.destination as? UINavigationController {
                let triTrackAddEventViewController = navController.topViewController as? TriTrackAddEventViewController
                triTrackAddEventViewController?.viewControllerValue = TriTrackViewControlSegmentValue(rawValue: triTrackSegmentedControl.selectedSegmentIndex)
            }

        case "embedShowSymptomsViewController":
            if let destinationVC = segue.destination as? SymptomsViewController {
                symptomsViewController = destinationVC
            }

        case "embedShowEventsViewController":
            if let destinationVC = segue.destination as? EventsViewController {
                eventsViewController = destinationVC
                destinationVC.triTrackViewController = self
            }

        default:
            break
        }
    }

    nonisolated func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        DispatchQueue.main.async {
            self.currentDateSelected = date
        }
    }

    @IBAction func segmentTapped(_ sender: UISegmentedControl) {
        updateView()
    }

    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
        symptomsViewController?.symptomsTableViewController?.refreshData()
        eventsViewController?.appointmentsTableViewController?.refreshData()
        eventsViewController?.remindersTableViewController?.refreshData()
    }

    // MARK: Private

    private var calendarView: FSCalendar!
    private var currentDateSelected: Date = .init()

    private func prepareCalendar() {
        calendarView = FSCalendar(frame: CGRect(x: 0, y: 0, width: calendarUIView.frame.width, height: calendarUIView.frame.height + 150))
        calendarView.scope = .week
        calendarView.select(Date())

        calendarView.dataSource = self
        calendarView.delegate = self

        calendarUIView.addSubview(calendarView)
    }
}
