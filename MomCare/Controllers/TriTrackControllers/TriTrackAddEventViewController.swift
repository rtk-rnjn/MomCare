//
//  TriTrackAddEventViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 16/01/25.
//

import UIKit

enum TriTrackViewControlSegmentValue: Int {
    case eventsReminderView = 1
    case symptomsView = 2
}

enum TriTrackEventReminderViewControlSegmentValue: Int {
    case event = 0
    case reminder = 1
}

class TriTrackAddEventViewController: UIViewController {
    /*
     if value == 1:
        show(eventReminderContainerView)
     elif value == 2:
        show(symptomsContainerView)
     else:
        Error(Something def. fucked up)
     */
    var viewControllerValue: TriTrackViewControlSegmentValue?

    @IBOutlet var reminderContainerView: UIView!
    @IBOutlet var eventContainerView: UIView!
    @IBOutlet var symptomsContainerView: UIView!

    @IBOutlet var eventReminderSegmentControl: UISegmentedControl!

    var addReminderTableViewController: AddReminderTableViewController?
    var addSymptomsTableViewController: AddSymptomsTableViewController?
    var addEventTableViewController: AddEventTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareContainerView()
    }
    
    func prepareContainerView() {
        guard viewControllerValue != nil else { return }
        switch viewControllerValue! {
        case .eventsReminderView:
            prepareEventReminderContainerView()
        case .symptomsView:
            prepareSymptomsContainerView()
        }
    }
    
    func prepareEventReminderContainerView() {
        symptomsContainerView.isHidden = true
        eventReminderSegmentControl.isHidden = false

        switch TriTrackEventReminderViewControlSegmentValue(rawValue: eventReminderSegmentControl.selectedSegmentIndex)! {
        case .event:
            eventContainerView.isHidden = false
            navigationItem.title = "Add Event"

            reminderContainerView.isHidden = true
        case .reminder:
            reminderContainerView.isHidden = false
            navigationItem.title = "Add Reminder"
            
            eventContainerView.isHidden = true
        }
    }

    @IBAction func eventReminderTapped(_ sender: UISegmentedControl) {
        prepareEventReminderContainerView()
    }
    
    func prepareSymptomsContainerView() {
        eventContainerView.isHidden = true
        reminderContainerView.isHidden = true
        eventReminderSegmentControl.isHidden = true
        
        symptomsContainerView.isHidden = false
        
        navigationItem.title = "Add Symptoms"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "embedSegueReminder":
            addReminderTableViewController = segue.destination as? AddReminderTableViewController
        case "embedSegueEvent":
            addEventTableViewController = segue.destination as? AddEventTableViewController
        case "embedSegueSymptoms":
            addSymptomsTableViewController = segue.destination as? AddSymptomsTableViewController
        default:
            break
        }
    }
}
