//
//  RemindersTableViewCell.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit

class RemindersTableViewCell: UITableViewCell {

    @IBOutlet var button: UIButton!
    @IBOutlet var label: UILabel!
    @IBOutlet var date: UIDatePicker!
    
    func prepareButton() {
    }

    func updateElements(labelText: String) {
        self.label.text = labelText
    }
}
