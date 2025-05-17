//
//  RemindersTableViewCell.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit
import EventKit

class RemindersTableViewCell: UITableViewCell {

    // MARK: Internal

    @IBOutlet var button: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var relativeTimeLabel: UILabel!

    var reminder: EKReminder?

    func updateElements(with reminder: EKReminder) {
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
        guard let reminder else { fatalError() }

        reminder.isCompleted = !reminder.isCompleted
        EventKitHandler.shared.updateReminder(reminder: reminder)

        updateElements(with: reminder)
    }

    // MARK: Private

    private func missed(_ reminder: EKReminder) -> Bool {
        if reminder.isCompleted {
            return false
        }

        if let date = reminder.dueDateComponents?.date {
            return date < Date()
        }

        return true
    }

}
