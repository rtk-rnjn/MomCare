//
//  AddSymptomsTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit
import SwiftUI

class AddSymptomsTableViewController: UITableViewController, UITextFieldDelegate {

    // MARK: Internal

    @IBOutlet var titleField: UITextField!
    @IBOutlet var notesField: UITextField!
    @IBOutlet var dateTime: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.delegate = self
        titleField.placeholder = "Select or add a symptom"
    }

    @IBAction func symptomButtonTapped(_ sender: UIButton) {
        showSymptomsSelector()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == titleField {
            titleField.isUserInteractionEnabled = false
        }
    }

    // MARK: Private

    private func showSymptomsSelector() {
        let symptomsListView = SymptomsListView { selectedSymptom in
            if let symptom = selectedSymptom {
                self.titleField.text = symptom.name
                self.titleField.isUserInteractionEnabled = false
                self.notesField.becomeFirstResponder()
            } else {
                self.titleField.text = ""
                self.titleField.isUserInteractionEnabled = true
                self.titleField.becomeFirstResponder()
            }
        }

        let hostingController = UIHostingController(rootView: symptomsListView)
        present(hostingController, animated: true, completion: nil)
    }

}
