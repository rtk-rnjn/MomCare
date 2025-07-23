//
//  TriTrackAddEventViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 16/01/25.
//

import UIKit
import EventKit

public enum TriTrackViewControlSegmentValue: Int {
    case eventsReminderView = 1
    case symptomsView = 2
}

public enum TriTrackEventReminderViewControlSegmentValue: Int {
    case eventView = 0
    case reminderView = 1
}

class TriTrackAddEventViewController: UIViewController {

    // MARK: Internal

    // if value == 1:
    //   show(eventReminderContainerView)
    // elif value == 2:
    //   show(symptomsContainerView)
    // else:
    //   Error(Something def. fucked up)
    var viewControllerValue: TriTrackViewControlSegmentValue?

    @IBOutlet var reminderContainerView: UIView!
    @IBOutlet var eventContainerView: UIView!
    @IBOutlet var symptomsContainerView: UIView!

    @IBOutlet var eventReminderSegmentControl: UISegmentedControl!

    var addReminderTableViewController: AddReminderTableViewController?
    var addSymptomsTableViewController: AddSymptomsTableViewController?
    var addEventTableViewController: AddEventTableViewController?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareContainerView()
    }
    
    override func viewDidLoad() {
        navigationController?.navigationBar.tintColor = UIColor(hex: "#924350")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "embedShowAddReminderTableViewController":
            addReminderTableViewController = segue.destination as? AddReminderTableViewController
        case "embedShowAddEventTableViewController":
            addEventTableViewController = segue.destination as? AddEventTableViewController
        case "embedShowAddSymptomsTableViewController":
            addSymptomsTableViewController = segue.destination as? AddSymptomsTableViewController
        default:
            break
            // OwO! What's this?
        }
    }

    @IBAction func eventReminderTapped(_ sender: UISegmentedControl) {
        prepareEventReminderContainerView()
    }

    // MARK: Private

    private func prepareContainerView() {
        guard viewControllerValue != nil else { return }
        switch viewControllerValue! {
        case .eventsReminderView:
            prepareEventReminderContainerView()
        case .symptomsView:
            prepareSymptomsContainerView()
        }
    }

    private func prepareEventReminderContainerView() {
        symptomsContainerView.isHidden = true
        eventReminderSegmentControl.isHidden = false

        switch TriTrackEventReminderViewControlSegmentValue(rawValue: eventReminderSegmentControl.selectedSegmentIndex) {
        case .eventView:
            eventContainerView.isHidden = false
            navigationItem.title = "Add Event"

            reminderContainerView.isHidden = true

        case .reminderView:
            reminderContainerView.isHidden = false
            navigationItem.title = "Add Reminder"

            eventContainerView.isHidden = true

        default:
            fatalError("Something def. fucked up")
        }
    }

    private func prepareSymptomsContainerView() {
        eventContainerView.isHidden = true
        reminderContainerView.isHidden = true
        eventReminderSegmentControl.isHidden = true

        symptomsContainerView.isHidden = false

        navigationItem.title = "Add Symptoms"
    }

}
