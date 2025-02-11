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
    @IBOutlet var dateTimePicker: UIDatePicker!

    func updateElements(with reminder: EKReminder) {
        titleLabel.text = reminder.title
        dateTimePicker.date = reminder.startDateComponents!.date!
    }
}
