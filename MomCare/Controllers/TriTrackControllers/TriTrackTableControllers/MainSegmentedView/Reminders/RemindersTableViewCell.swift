//
//  RemindersTableViewCell.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit

class RemindersTableViewCell: UITableViewCell {

    @IBOutlet var button: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateTime: UIDatePicker!

    func updateElements(with reminder: TriTrackReminder) {
        titleLabel.text = reminder.title
    }
}
