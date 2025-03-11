//
//  HealthPreferencesTableViewController.swift
//  MomCare
//
//  Created by Khushi Rana on 02/03/25.
//

import UIKit

class HealthPreferencesTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var dietPreferneceOutlet: UIButton!
    @IBOutlet var exerciseLevelOutlet: UIButton!

    var isEditingMode: Bool = false
    var pickerView: UIPickerView! = .init()
    var activeButton: UIButton?
    var currentPickerData: [String] = []

    // Picker Values
    var dietPreferenceData: DietaryPreference = .allCases
    var exerciseLevelData: [String] = ["Beginner", "Intermediate", "Advanced"]

    override func viewDidLoad() {
        super.viewDidLoad()
        updateElements()
        setUpPickers()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEditingMode))

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    func setUpPickers() {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.systemGray5
        pickerView.frame = CGRect(x: 0, y: view.frame.height - 350, width: view.frame.width, height: 215)
        pickerView.isHidden = true
        view.addSubview(pickerView)
    }

    @objc func dismissPicker() {
        pickerView.isHidden = true
    }

    @objc func toggleEditingMode() {
        isEditingMode = !isEditingMode
        navigationItem.rightBarButtonItem?.title = isEditingMode ? "Save" : "Edit"

        UpdateUIForEditingMode()
        tableView.reloadData()
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        activeButton = sender
        switch sender {
        case dietPreferneceOutlet:
            currentPickerData = dietPreferenceData.map { $0.rawValue }
        case exerciseLevelOutlet:
            currentPickerData = exerciseLevelData
        default:
            return
        }

        pickerView.reloadAllComponents()
        pickerView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.pickerView.alpha = 1.0
        }
    }

    func UpdateUIForEditingMode() {
        dietPreferneceOutlet.isUserInteractionEnabled = isEditingMode
        exerciseLevelOutlet.isUserInteractionEnabled = isEditingMode
    }

    func updateElements() {
        dietPreferneceOutlet.setTitle("Not Set", for: .normal)
        exerciseLevelOutlet.setTitle("Not Set", for: .normal)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentPickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currentPickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        activeButton?.setTitle(currentPickerData[row], for: .normal)
    }
}
