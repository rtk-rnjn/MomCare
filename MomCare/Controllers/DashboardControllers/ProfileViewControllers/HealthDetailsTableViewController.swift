//
//  HealthDetailsTableViewController.swift
//  MomCare
//
//  Created by Khushi Rana on 02/03/25.
//

import UIKit

class HealthDetailsTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet var dueDatePicker: UIDatePicker!
    @IBOutlet var bloodGroupOutlet: UIButton!
    @IBOutlet var MedicalConditionsOutlet: UIButton!
    @IBOutlet var allergeisOutlet: UIButton!

    var isEditingMode: Bool = false
    var pickerView: UIPickerView = .init()
    var activeButton: UIButton?
    var currentPickerData: [String] = .init()

   //    Picker values
    let bloodGroupValues = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
    let MedicalConditionsValues: PreExistingCondition = .allCases
    let AllergiesValues: Intolerance = .allCases

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
        case bloodGroupOutlet:
            currentPickerData = bloodGroupValues
        case MedicalConditionsOutlet:
            currentPickerData = MedicalConditionsValues.map { $0.rawValue }
        case allergeisOutlet:
            currentPickerData = AllergiesValues.map { $0.rawValue }
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
        dueDatePicker.isUserInteractionEnabled = isEditingMode
        bloodGroupOutlet.isUserInteractionEnabled = isEditingMode
        MedicalConditionsOutlet.isUserInteractionEnabled = isEditingMode
        allergeisOutlet.isUserInteractionEnabled = isEditingMode
    }

    func updateElements() {
        guard let medicalData = MomCareUser.shared.user?.medicalData else { return }

        dueDatePicker.date = medicalData.dueDate!
        bloodGroupOutlet.setTitle("Not Set", for: .normal)
        MedicalConditionsOutlet.setTitle("None", for: .normal)
        allergeisOutlet.setTitle(String("None"), for: .normal)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }

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
