//
//  SymptomsTableViewCell.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit

class SymptomsTableViewCell: UITableViewCell {

    @IBOutlet var dateTime: UIDatePicker!
    @IBOutlet var titleLabel: UILabel!

    func updateElements(with symptom: EventInfo) {
        dateTime.date = symptom.startDate ?? .init()
        titleLabel.text = symptom.title
    }
}
