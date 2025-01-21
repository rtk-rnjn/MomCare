//
//  AppointmentsTableViewCell.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit

class AppointmentsTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var dateTime: UIDatePicker!

    func updateElements(with event: TriTrackEvent) {
        dateTime.date = event.startDate
        titleLabel.text = event.title

    }

}
