//
//  AddSymptomsTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit
import EventKit

class AddSymptomsTableViewController: UITableViewController {

    @IBOutlet var titleField: UITextField!
    @IBOutlet var notesField: UITextField!
    @IBOutlet var dateTime: UIDatePicker!
    
    var symptomToEdit: EKEvent?

    override func viewDidLoad() {
        super.viewDidLoad()

        titleField.text = symptomToEdit?.title
        notesField.text = symptomToEdit?.notes ?? ""
        dateTime.date = symptomToEdit?.startDate ?? dateTime.date
    }
}
