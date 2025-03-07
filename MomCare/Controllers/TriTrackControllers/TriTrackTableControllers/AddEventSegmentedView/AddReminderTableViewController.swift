//
//  AddReminderTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit

class AddReminderTableViewController: UITableViewController {

    // MARK: Internal

    static let options: [String: TimeInterval] = [
        "Never": -1,
        "Every Day": 24 * 60 * 60,
        "Every Week": 24 * 60 * 60 * 7,
        "Every 2 Week": 24 * 60 * 60 * 7 * 2,
        "Every Month": 24 * 60 * 60 * 7 * 30,
        "Every Year": 24 * 60 * 60 * 7 * 30 * 12
    ]

    @IBOutlet var dateTime: UIDatePicker!

    @IBOutlet var titleField: UITextField!
    @IBOutlet var notesField: UITextField!

    @IBOutlet var repeatPopupButton: UIButton!

    var selectedRepeatOption: TimeInterval = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        dateTime.minimumDate = Date()

        prepareRepeatPopup()
    }

    // MARK: Private

    private func prepareRepeatPopup() {
        repeatPopupButton.menu = UIMenu(children: AddReminderTableViewController.options.map { title, _ in
            UIAction(title: title, handler: handleRepeatOption) })

        repeatPopupButton.showsMenuAsPrimaryAction = true
        repeatPopupButton.changesSelectionAsPrimaryAction = true
    }

    private func handleRepeatOption(action: UIAction) {
        repeatPopupButton.setTitle(action.title, for: .normal)
        selectedRepeatOption = AddReminderTableViewController.options[action.title]!
    }
}
