//
//  AddEventTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit

class AddEventTableViewController: UITableViewController {

    static let repeatTimeOptions: [String: TimeInterval] = [
        "Never": -1,
        "Every Day": 24 * 60 * 60,
        "Every Week": 24 * 60 * 60 * 7,
        "Every 2 Week": 24 * 60 * 60 * 7 * 2,
        "Every Month": 24 * 60 * 60 * 7 * 30,
        "Every Year": 24 * 60 * 60 * 7 * 30 * 12
    ]

    static let travelTimeOptions: [String: TimeInterval] = [
        "None": -1,
        "5 Minutes": 5 * 60,
        "10 Minutes": 10 * 60,
        "15 Minutes": 15 * 60,
        "30 Minutes": 30 * 60,
        "1 Hour": 60 * 60,
        "1 Hour, 30 Minutes": 90 * 60,
        "2 Hours": 120 * 60
    ]

    static let alertTimeOptions: [String: TimeInterval] = [
        "None": -1,
        "At time of event": 0,
        "5 Minutes before": 5 * 60,
        "10 Minutes before": 10 * 60,
        "15 Minutes before": 15 * 60,
        "30 Minutes before": 30 * 60,
        "1 Hour before": 60 * 60,
        "2 Hours before": 120 * 60,
        "1 Day before": 24 * 60 * 60,
        "2 Day before": 24 * 60 * 60 * 2,
        "1 Week before": 24 * 60 * 60 * 7
    ]

    @IBOutlet var literalEndsLabel: UILabel!
    @IBOutlet var startDateTimePicker: UIDatePicker!
    @IBOutlet var endDateTimePicker: UIDatePicker!

    @IBOutlet var allDaySwitch: UISwitch!
    @IBOutlet var repeatPopupButton: UIButton!
    @IBOutlet var travelTimePopupButton: UIButton!
    @IBOutlet var alertTimePopupButton: UIButton!

    @IBOutlet var titleField: UITextField!
    @IBOutlet var locationField: UITextField!

    var selectedRepeatOption: TimeInterval = -1
    var selectedTravelTimeOption: TimeInterval = -1
    var selectedAlertTimeOption: TimeInterval = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        endDateTimePicker.minimumDate = Date()

        preparePopupButtons()
    }

    @IBAction func allDaySwitchTapped(_ sender: UISwitch) {
        if sender.isOn {
            endDateTimePicker.isUserInteractionEnabled = false
            endDateTimePicker.alpha = 0.5
            literalEndsLabel.alpha = 0.5
        } else {
            endDateTimePicker.isUserInteractionEnabled = true
            endDateTimePicker.alpha = 1
            literalEndsLabel.alpha = 1
        }
    }

    private func preparePopupButtons() {
        prepareRepeatPopup()
        prepareTravelTimePopup()
        prepareAlertTimePopup()
    }

    private func prepareRepeatPopup() {
        repeatPopupButton.menu = UIMenu(children: AddEventTableViewController.repeatTimeOptions.map { title, _ in
            UIAction(title: title, handler: handleRepeatOption) })

        repeatPopupButton.showsMenuAsPrimaryAction = true
        repeatPopupButton.changesSelectionAsPrimaryAction = true
    }

    private func handleRepeatOption(action: UIAction) {
        repeatPopupButton.setTitle(action.title, for: .normal)
        selectedRepeatOption = AddEventTableViewController.repeatTimeOptions[action.title]!
    }

    private func prepareTravelTimePopup() {
        travelTimePopupButton.menu = UIMenu(children: AddEventTableViewController.travelTimeOptions.map { title, _ in
            UIAction(title: title, handler: handleTravelTimeOption) })

        travelTimePopupButton.showsMenuAsPrimaryAction = true
        travelTimePopupButton.changesSelectionAsPrimaryAction = true
    }

    private func handleTravelTimeOption(action: UIAction) {
        travelTimePopupButton.setTitle(action.title, for: .normal)
        selectedTravelTimeOption = AddEventTableViewController.travelTimeOptions[action.title]!
    }

    private func prepareAlertTimePopup() {
        alertTimePopupButton.menu = UIMenu(children: AddEventTableViewController.alertTimeOptions.map { title, _ in
            UIAction(title: title, handler: handleAlertTimeOption) })

        alertTimePopupButton.showsMenuAsPrimaryAction = true
        alertTimePopupButton.changesSelectionAsPrimaryAction = true
    }

    private func handleAlertTimeOption(action: UIAction) {
        alertTimePopupButton.setTitle(action.title, for: .normal)
        selectedAlertTimeOption = AddEventTableViewController.alertTimeOptions[action.title]!
    }
}
