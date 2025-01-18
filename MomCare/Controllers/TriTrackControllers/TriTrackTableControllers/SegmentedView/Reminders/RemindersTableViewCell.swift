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
    
    func prepareButton() {
        button.layer.cornerRadius = button.bounds.size.width / 2
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemBlue.cgColor
    }

    func updateElements(with reminder: TriTrackReminder) {
        titleLabel.text = reminder.title
        dateTime.date = Date(timeIntervalSinceNow: reminder.duration ?? 0)
        
        prepareButton()
    }
}
