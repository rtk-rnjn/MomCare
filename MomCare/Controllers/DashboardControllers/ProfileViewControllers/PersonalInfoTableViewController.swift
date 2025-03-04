//
//  PersonalInfoTableViewController.swift
//  MomCare
//
//  Created by Khushi Rana on 02/03/25.
//

import UIKit

class PersonalInfoTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var userName: UITextField!
    @IBOutlet var userAge: UITextField!
    @IBOutlet var userDOB: UIDatePicker!
    @IBOutlet var userHeight: UIButton!
    @IBOutlet var userCurrentWeight: UIButton!
    @IBOutlet var userPrePregnancyWeight: UIButton!
    @IBOutlet var userPregnancyDay: UIButton!
    @IBOutlet var userPregnancyWeek: UIButton!
    @IBOutlet var userTrimester: UIButton!
    @IBOutlet var userPhoneNumber: UIButton!

    var isEditingMode = false
    var pickerView: UIPickerView = .init()
    var activeButton: UIButton?
    var currentPickerData: [String] = .init()

    let heightValues = Array(140...200).map { "\($0) cm" }
    let weightValues = Array(40...120).map { "\($0) kgs" }
    let dayValues = Array(1...7).map { "\($0)" }
    let weekValues = Array(1...40).map { "\($0)" }
    let trimesterValues = ["I", "II", "III"]

    override func viewDidLoad() {
        super.viewDidLoad()
        updateElements()
        setupPickers()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEditMode))

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func toggleEditMode() {
    isEditingMode.toggle()

    navigationItem.rightBarButtonItem?.title = isEditingMode ? "Save" : "Edit"
    updateUIForEditingMode()

    tableView.reloadData()
    }

    func setupPickers() {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.systemGray5
        pickerView.frame = CGRect(x: 0, y: view.frame.height - 350, width: view.frame.width, height: 215)

        pickerView.isHidden = true
        view.addSubview(pickerView)
    }

    func updateUIForEditingMode() {
        userName.isUserInteractionEnabled = isEditingMode
        userAge.isUserInteractionEnabled = isEditingMode
        userDOB.isUserInteractionEnabled = isEditingMode
        userHeight.isUserInteractionEnabled = isEditingMode
        userCurrentWeight.isUserInteractionEnabled = isEditingMode
        userPrePregnancyWeight.isUserInteractionEnabled = isEditingMode
        userPregnancyDay.isUserInteractionEnabled = isEditingMode
        userPregnancyWeek.isUserInteractionEnabled = isEditingMode
        userTrimester.isUserInteractionEnabled = isEditingMode
        userPhoneNumber.isUserInteractionEnabled = isEditingMode
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
            activeButton = sender
            switch sender {
            case userHeight:
                currentPickerData = heightValues
            case userCurrentWeight, userPrePregnancyWeight:
                currentPickerData = weightValues
            case userPregnancyDay:
                currentPickerData = dayValues
            case userPregnancyWeek:
                currentPickerData = weekValues
            case userTrimester:
                currentPickerData = trimesterValues
            default:
                return
            }

            pickerView.reloadAllComponents()
            pickerView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                    self.pickerView.alpha = 1.0
            }
        }

    @objc func dismissPicker() {
        pickerView.isHidden = true
    }

    @objc func donePicker() {
        if let button = activeButton {
            let selectedRow = pickerView.selectedRow(inComponent: 0)
            button.setTitle(currentPickerData[selectedRow], for: .normal)
        }

        pickerView.isHidden = true
        activeButton?.resignFirstResponder()
        view.endEditing(true)
    }

    func calculateAge(from dob: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: dob, to: now)
        return ageComponents.year ?? 0
    }

    func updateElements() {
        guard let userMedical = MomCareUser.shared.user?.medicalData else { return }
        guard let user = MomCareUser.shared.user else { return }

        userName.text = user.fullName
        userDOB.date = userMedical.dateOfBirth
        userHeight.setTitle("\(userMedical.height) cm", for: .normal)
        userCurrentWeight.setTitle("\(userMedical.currentWeight) kgs", for: .normal)
        userPrePregnancyWeight.setTitle("\(userMedical.prePregnancyWeight) kgs", for: .normal)

        let weekAndDay = Utils.pregnancyWeekAndDay(dueDate: userMedical.dueDate!)

        userPregnancyDay.setTitle(String(weekAndDay?.day ?? 0), for: .normal)
        userPregnancyWeek.setTitle(String(weekAndDay?.week ?? 0), for: .normal)
        userTrimester.setTitle(String(weekAndDay?.trimester ?? "Not Set"), for: .normal)
        userPhoneNumber.setTitle(user.phoneNumber, for: .normal)

        let dob = userMedical.dateOfBirth
        let age = calculateAge(from: dob)
        userAge.text = "\(age)"

        userDOB.date = userMedical.dateOfBirth
    }

        // MARK: - UIPickerView Delegate & DataSource
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
