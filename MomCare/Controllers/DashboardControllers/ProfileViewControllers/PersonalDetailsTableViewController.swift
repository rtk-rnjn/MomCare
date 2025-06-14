//
//  PersonalInfoTableViewController.swift
//  MomCare
//
//  Created by Khushi Rana on 02/03/25.
//

import UIKit

class PersonalDetailsTableViewController: UITableViewController {

    @IBOutlet var userNameField: UITextField!
    @IBOutlet var userDatOfBirthPicker: UIDatePicker!
    @IBOutlet var userHeightButton: UIButton!
    @IBOutlet var userCurrentWeightButton: UIButton!
    @IBOutlet var userPrePregnancyWeightButton: UIButton!
    @IBOutlet var userPregnancyDayButton: UIButton!
    @IBOutlet var userPregnancyWeekButton: UIButton!
    @IBOutlet var userTrimesterButton: UIButton!

    var isEditingMode = false
    var pickerView: UIPickerView = .init()
    var activeButton: UIButton?
    var currentPickerData: [String] = .init()

    let heightValues = Array(140...200).map { "\($0) cm" }
    let weightValues = Array(40...200).map { "\($0) kgs" }
    let dayValues = Array(1...7).map { "\($0)" }
    let weekValues = Array(1...40).map { "\($0)" }
    let trimesterValues = ["I", "II", "III"]

    override func viewDidLoad() {
        super.viewDidLoad()
        updateElements()
        setupPickers()
    
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        isEditingMode.toggle()
        sender.title = isEditingMode ? "Save" : "Edit"
        toggleEditMode()
    }
    
    func toggleEditMode() {
        updateUIForEditingMode()
            
            if !isEditingMode {
                Task{
                    await saveUser()
                }
            }
    }

    func updateUIForEditingMode() {
        userNameField.isUserInteractionEnabled = isEditingMode
        userDatOfBirthPicker.isUserInteractionEnabled = isEditingMode
        userHeightButton.isUserInteractionEnabled = isEditingMode
        userCurrentWeightButton.isUserInteractionEnabled = isEditingMode
        userPrePregnancyWeightButton.isUserInteractionEnabled = isEditingMode
    }

    @IBAction func fieldValuesButtonTapped(_ sender: UIButton) {
            activeButton = sender
            switch sender {
            case userHeightButton:
                currentPickerData = heightValues
            case userCurrentWeightButton, userPrePregnancyWeightButton:
                currentPickerData = weightValues
            case userPregnancyDayButton:
                currentPickerData = dayValues
            case userPregnancyWeekButton:
                currentPickerData = weekValues
            case userTrimesterButton:
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

        userNameField.text = user.fullName
        userDatOfBirthPicker.date = userMedical.dateOfBirth
        userHeightButton.setTitle("\(userMedical.height) cm", for: .normal)
        userCurrentWeightButton.setTitle("\(userMedical.currentWeight) kgs", for: .normal)
        userPrePregnancyWeightButton.setTitle("\(userMedical.prePregnancyWeight) kgs", for: .normal)

        let weekAndDay = Utils.pregnancyWeekAndDay(dueDate: userMedical.dueDate!)

        userPregnancyDayButton.setTitle(String(weekAndDay?.day ?? 0), for: .normal)
        userPregnancyWeekButton.setTitle(String(weekAndDay?.week ?? 0), for: .normal)
        userTrimesterButton.setTitle(String(weekAndDay?.trimester ?? "Not Set"), for: .normal)
        userDatOfBirthPicker.date = userMedical.dateOfBirth
    }
    
    func saveUser() async{
        MomCareUser.shared.user?.medicalData?.dateOfBirth = userDatOfBirthPicker.date
        
        if let fullName = userNameField.text {
            let nameParts = fullName.split(separator: " ")
            MomCareUser.shared.user?.firstName = nameParts.first.map(String.init) ?? ""
            MomCareUser.shared.user?.lastName = nameParts.dropFirst().joined(separator: " ")
        }
        
        if let heightText = userHeightButton.title(for: .normal)?.replacingOccurrences(of: " cm", with: ""),
               let height = Double(heightText) {
            MomCareUser.shared.user?.medicalData?.height = height
        }
        
        if let weightText = userCurrentWeightButton.title(for: .normal)?.replacingOccurrences(of: " kgs", with: ""),
               let weight = Double(weightText) {
            MomCareUser.shared.user?.medicalData?.currentWeight = weight
        }

        if let preWeightText = userPrePregnancyWeightButton.title(for: .normal)?.replacingOccurrences(of: " kgs", with: ""),
           let preWeight = Double(preWeightText) {
            MomCareUser.shared.user?.medicalData?.prePregnancyWeight = preWeight
        }
    }
}

extension PersonalDetailsTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func setupPickers() {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.systemGray5
        pickerView.frame = CGRect(x: 0, y: view.frame.height - 350, width: view.frame.width, height: 215)

        pickerView.isHidden = true
        view.addSubview(pickerView)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentPickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currentPickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {   activeButton?.setTitle(currentPickerData[row], for: .normal)
    }
    
    @objc func dismissPicker() {
        pickerView.isHidden = true
    }
}
