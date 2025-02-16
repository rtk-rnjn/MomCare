//
//  AllSymptomsTableViewCell.swift
//  MomCare
//
//  Created by Ritik Ranjan on 20/01/25.
//

import UIKit
import EventKit

class AllSymptomsTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateTimePicker: UIDatePicker!

    func updateElements(with symptom: EKEvent) {
        titleLabel.text = symptom.title
        dateTimePicker.date = symptom.startDate
    }
}
