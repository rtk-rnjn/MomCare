//
//  AllRemindersTableViewCell.swift
//  MomCare
//
//  Created by Ritik Ranjan on 20/01/25.
//

import UIKit
import EventKit

class AllRemindersTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var relativeTimeLabel: UILabel!
    @IBOutlet var button: UIButton!
    var reminder: EKReminder?
    var store: EKEventStore?

    func updateElements(with reminder: EKReminder, for store: EKEventStore?) {
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
        self.store = store
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        guard let reminder, let store else { fatalError() }

        reminder.isCompleted = !reminder.isCompleted
        try? store.save(reminder, commit: true)

        updateElements(with: reminder, for: store)
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
