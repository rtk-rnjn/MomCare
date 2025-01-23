//
//  AllSymptomsTableViewCell.swift
//  MomCare
//
//  Created by Ritik Ranjan on 20/01/25.
//

import UIKit

class AllSymptomsTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateTimePicker: UIDatePicker!

    func updateElements(with symptom: TriTrackSymptom) {
        titleLabel.text = symptom.title
        dateTimePicker.date = symptom.atTime
    }
}
