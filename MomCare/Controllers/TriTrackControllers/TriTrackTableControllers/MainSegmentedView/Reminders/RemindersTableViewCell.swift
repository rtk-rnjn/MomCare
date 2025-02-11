//
//  RemindersTableViewCell.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit
import EventKit

class RemindersTableViewCell: UITableViewCell {

    @IBOutlet var button: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var relativeTimeLabel: UILabel!

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
        
        self.reminder = reminder
        self.store = store
    }
    
    private func missed(_ reminder: EKReminder) -> Bool {
        if reminder.isCompleted {
            return false
        }
        
        if let date = reminder.dueDateComponents?.date {
            return date < Date()
        }
        
        return true
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        print("Button tapped")
    }
    
}

