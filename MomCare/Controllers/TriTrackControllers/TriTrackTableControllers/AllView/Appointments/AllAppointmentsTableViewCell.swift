//
//  AllAppointmentsTableViewCell.swift
//  MomCare
//
//  Created by Ritik Ranjan on 20/01/25.
//

import UIKit
import EventKit

class AllAppointmentsTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var notesLabel: UILabel!
    @IBOutlet var dateTimePicker: UIDatePicker!

    func updateElements(with appointment: EKEvent) {
        titleLabel.text = appointment.title
        notesLabel.text = appointment.location

        if appointment.location?.trimmingCharacters(in: .whitespaces).isEmpty ?? true {
            notesLabel.isHidden = true
        }

        dateTimePicker.date = appointment.startDate
    }
}
