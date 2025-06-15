//
//  RemindersTableViewCell.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit

class RemindersTableViewCell: UITableViewCell {

    // MARK: Internal

    @IBOutlet var button: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var relativeTimeLabel: UILabel!

    var reminder: ReminderInfo?

    func updateElements(with reminder: ReminderInfo) {
        titleLabel.text = reminder.title
        relativeTimeLabel.text = Date().relativeString(from: reminder.dueDateComponents?.date)

        if missed(reminder) {
            relativeTimeLabel.textColor = .red
        } else {
            relativeTimeLabel.textColor = .black
        }

        let circleImage = UIImage(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
        button.setImage(circleImage, for: .normal)

        self.reminder = reminder
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        reminder?.isCompleted = !(reminder?.isCompleted ?? false)
        guard let reminder else { return }

        Task {
            await EventKitHandler.shared.updateReminder(reminder: reminder)
            DispatchQueue.main.async {
                self.updateElements(with: reminder)
            }
        }
    }

    // MARK: Private

    private func missed(_ reminder: ReminderInfo) -> Bool {
        if reminder.isCompleted {
            return false
        }

        if let date = reminder.dueDateComponents?.date {
            return date < Date()
        }

        return true
    }

}
