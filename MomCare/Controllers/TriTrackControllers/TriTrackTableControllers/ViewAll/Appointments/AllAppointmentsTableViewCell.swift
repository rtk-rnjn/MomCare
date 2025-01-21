//
//  AllAppointmentsTableViewCell.swift
//  MomCare
//
//  Created by Ritik Ranjan on 20/01/25.
//

import UIKit

class AllAppointmentsTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var notesLabel: UILabel!
    @IBOutlet var dateTimePicker: UIDatePicker!
    
    func updateElements(with appointment: TriTrackEvent) {
        titleLabel.text = appointment.title
        notesLabel.text = appointment.location
        dateTimePicker.date = appointment.startDate
    }
}
