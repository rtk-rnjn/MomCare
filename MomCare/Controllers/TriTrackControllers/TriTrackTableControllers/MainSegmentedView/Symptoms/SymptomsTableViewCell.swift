//
//  SymptomsTableViewCell.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit
import EventKit

class SymptomsTableViewCell: UITableViewCell {

    @IBOutlet var dateTime: UIDatePicker!
    @IBOutlet var titleLabel: UILabel!

    func updateElements(with symptom: EKEvent) {
        dateTime.date = symptom.startDate
        titleLabel.text = symptom.title
    }
}
