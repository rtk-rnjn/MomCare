//
//  EventsViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit

class EventsViewController: UIViewController {
    var appointmentsTableViewController: AppointmentsTableViewController?
    var remindersTableViewController: RemindersTableViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appointmentsTableViewController?.refreshData()
        remindersTableViewController?.refreshData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let appointmentIdentifier = "embedShowAppointmentsTabelViewController"
        let reminderIdentifier = "embedShowRemindersTabelViewController"
        
        switch segue.identifier {
        case appointmentIdentifier:
            appointmentsTableViewController = segue.destination as? AppointmentsTableViewController
        case reminderIdentifier:
            remindersTableViewController = segue.destination as? RemindersTableViewController
        default:
            break
        }
    }
}
