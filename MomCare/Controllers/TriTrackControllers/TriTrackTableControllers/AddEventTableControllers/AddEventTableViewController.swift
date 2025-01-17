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
    @IBOutlet var dateTimePicker: UIDatePicker!

    @IBOutlet var repeatPopupButton: UIButton!
    @IBOutlet var travelTimePopupButton: UIButton!
    @IBOutlet var alertTimePopupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateTimePicker.minimumDate = Date()
        
        preparePopupButtons()
    }

    @IBAction func allDaySwitchTapped(_ sender: UISwitch) {
        if sender.isOn {
            dateTimePicker.isUserInteractionEnabled = false
            dateTimePicker.alpha = 0.5
            literalEndsLabel.alpha = 0.5
        } else {
            dateTimePicker.isUserInteractionEnabled = true
            dateTimePicker.alpha = 1
            literalEndsLabel.alpha = 1
        }
    }
    
    private func preparePopupButtons() {
        prepareRepeatPopup()
        prepareTravelTimePopup()
        prepareAlertTimePopup()
    }
    
    private func prepareRepeatPopup() {
        repeatPopupButton.menu = UIMenu(children: AddEventTableViewController.repeatTimeOptions.map { title, interval in
            UIAction(title: title, handler: handleRepeatOption) })
        
        repeatPopupButton.showsMenuAsPrimaryAction = true
        repeatPopupButton.changesSelectionAsPrimaryAction = true
    }
    
    private func handleRepeatOption(action: UIAction) {
        repeatPopupButton.setTitle(action.title, for: .normal)
        print(AddEventTableViewController.repeatTimeOptions[action.title]!)
    }

    private func prepareTravelTimePopup() {
        travelTimePopupButton.menu = UIMenu(children: AddEventTableViewController.travelTimeOptions.map { title, interval in
            UIAction(title: title, handler: handleTravelTimeOption) })
        
        travelTimePopupButton.showsMenuAsPrimaryAction = true
        travelTimePopupButton.changesSelectionAsPrimaryAction = true
    }
    
    private func handleTravelTimeOption(action: UIAction) {
        travelTimePopupButton.setTitle(action.title, for: .normal)
        print(AddEventTableViewController.travelTimeOptions[action.title]!)
    }
    
    private func prepareAlertTimePopup() {
        alertTimePopupButton.menu = UIMenu(children: AddEventTableViewController.alertTimeOptions.map { title, interval in
            UIAction(title: title, handler: handleAlertTimeOption) })
        
        alertTimePopupButton.showsMenuAsPrimaryAction = true
        alertTimePopupButton.changesSelectionAsPrimaryAction = true
    }
    
    private func handleAlertTimeOption(action: UIAction) {
        alertTimePopupButton.setTitle(action.title, for: .normal)
        print(AddEventTableViewController.alertTimeOptions[action.title]!)
    }
}
