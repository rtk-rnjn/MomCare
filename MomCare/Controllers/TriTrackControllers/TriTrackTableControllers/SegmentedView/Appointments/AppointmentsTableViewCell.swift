//
//  AppointmentsTableViewCell.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit

class AppointmentsTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var notesLabel: UILabel!
    @IBOutlet var dateTime: UIDatePicker!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateElements(title: String, notes: String) {
        self.titleLabel.text = title
        self.notesLabel.text = notes
    }

}
