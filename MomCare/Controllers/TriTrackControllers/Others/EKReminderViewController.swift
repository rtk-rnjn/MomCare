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

    var reminder: ReminderInfo!

    @IBOutlet var reminderLabel: UILabel!
    @IBOutlet var completeButton: UIButton!
    @IBOutlet var deleteButton: UIButton!

    var reloadHandler: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }

    @IBAction func deleteButtonTapped(_ sender: Any) {
        let alertActions = [
            AlertActionHandler(title: "Cancel", style: .cancel, handler: nil),
            AlertActionHandler(title: "Delete", style: .destructive) { _ in
                Task {
                    await EventKitHandler.shared.deleteReminder(reminder: self.reminder)
                    DispatchQueue.main.async {
                        self.dismiss(animated: true) {
                            self.reloadHandler?()
                        }
                    }
                }
            }
        ]

        let alert = Utils.getAlert(title: "Delete Reminder?", message: "Are you sure you want to delete this reminder?", actions: alertActions)

        present(alert, animated: true)
    }

    @IBAction func markAsCompletedButtonTapped(_ sender: UIButton) {
        updateView()
        reminder.isCompleted = !reminder.isCompleted
        Task {
            await EventKitHandler.shared.updateReminder(reminder: reminder)
        }
    }

    // MARK: Private

    private func updateView() {
        reminderLabel.text = reminder.title

        if !reminder.isCompleted {
            completeButton.titleLabel?.text = "Mark as Complete"
        } else {
            completeButton.titleLabel?.text = "Mark as Incomplete"
        }
    }

}
