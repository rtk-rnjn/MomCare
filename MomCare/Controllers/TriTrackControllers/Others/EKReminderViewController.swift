//
//  EKReminderViewController.swift
//  MomCare
//
//  Created by RITIK RANJAN on 12/02/25.
//

import UIKit
import EventKit

class EKReminderViewController: UITableViewController {

    // MARK: Internal

    var reminder: EKReminder!
    var store: EKEventStore!

    @IBOutlet var completeButton: UIButton!
    @IBOutlet var deleteButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }

    @IBAction func deleteButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    // MARK: Private

    private func updateView() {
        if !reminder.isCompleted {
            completeButton.titleLabel?.text = "Mark as Complete"
        } else {
            completeButton.titleLabel?.text = "Mark as Incomplete"
        }
    }

}
