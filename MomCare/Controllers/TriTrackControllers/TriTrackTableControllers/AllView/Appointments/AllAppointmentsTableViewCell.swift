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

    func updateElements(with appointment: EventInfo) {

        titleLabel.text = appointment.title

        notesLabel.text = appointment.location

        if appointment.location?.trimmingCharacters(in: .whitespaces).isEmpty ?? true {

            notesLabel.isHidden = true

        }

    }

}
