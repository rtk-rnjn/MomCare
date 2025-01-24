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

    var symptomsViewController: SymptomsViewController?
    var eventsViewController: EventsViewController?

    var currentSegmentValue: Int = 0
    private var currentDateSelected = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCalendar()
    }

    private func prepareCalendar() {
        calendarView = FSCalendar(frame: CGRect(x: 0, y: 0, width: calendarUIView.frame.width, height: calendarUIView.frame.height + 150))
        calendarView.scope = .week
        calendarView.select(Date())

        calendarView.dataSource = self
        calendarView.delegate = self

        calendarUIView.addSubview(calendarView)
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        currentDateSelected = date
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        triTrackInternalView.backgroundColor = .white
        triTrackInternalView.layer.cornerRadius = 15

        prepareSegmentedControl()
        updateView()
    }

    @IBAction func segmentTapped(_ sender: UISegmentedControl) {
        updateView()
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
