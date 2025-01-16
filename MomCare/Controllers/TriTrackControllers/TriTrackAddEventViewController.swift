//
//  TriTrackAddEventViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 16/01/25.
//

import UIKit

class TriTrackAddEventViewController: UIViewController {
    /*
     if value == 1:
        show(eventReminderContainerView)
     elif value == 2:
        show(symptomsContainerView)
     else:
        Error(Something def. fucked up)
     */
    var viewControllerValue: Int?

    @IBOutlet var reminderContainerView: UIView!
    @IBOutlet var eventContainerView: UIView!
    @IBOutlet var symptomsContainerView: UIView!

    @IBOutlet var eventReminderSegmentControl: UISegmentedControl!
    var currentSegmentIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareContainerView()
    }
    
    func prepareContainerView() {
        guard viewControllerValue != nil else { return }
        switch viewControllerValue {
        case 1:
            prepareEventReminderContainerView()
        case 2:
            prepareSymptomsContainerView()
        default:
            fatalError("Help me God")
        }
    }
    
    func prepareEventReminderContainerView() {
        symptomsContainerView.isHidden = true

        switch currentSegmentIndex {
        case 0:
            eventContainerView.isHidden = false
            navigationItem.title = "Add Event"
            
            reminderContainerView.isHidden = true
        case 1:
            reminderContainerView.isHidden = false
            navigationItem.title = "Add Reminder"
            
            eventContainerView.isHidden = true
        default:
            fatalError()
        }
    }

    @IBAction func eventReminderTapped(_ sender: UISegmentedControl) {
        currentSegmentIndex = sender.selectedSegmentIndex
        prepareEventReminderContainerView()
    }
    
    func prepareSymptomsContainerView() {
        eventContainerView.isHidden = true
        reminderContainerView.isHidden = true
        eventReminderSegmentControl.isHidden = true
        
        symptomsContainerView.isHidden = false
        
        navigationItem.title = "Add Symptoms"
    }
}
