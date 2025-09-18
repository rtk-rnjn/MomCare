//
//  AppointmentsTableViewCell.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit
import EventKit

class AppointmentsTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateTime: UIDatePicker!

    func updateElements(with event: EventInfo) {
        dateTime.date = event.startDate
        titleLabel.text = event.title
    }
}
