//
//  PersonalInfoTableViewController.swift
//  MomCare
//
//  Created by Khushi Rana on 02/03/25.
//

import UIKit

class PersonalInfoTableViewController: UITableViewController,UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet var userName: UILabel!
    @IBOutlet var userAge: UILabel!
    @IBOutlet var userDOB: UIDatePicker!
    @IBOutlet var userHeight: UIButton!
    @IBOutlet var userCurrentWeight: UIButton!
    @IBOutlet var userPrePregnancyWeight: UIButton!
    @IBOutlet var userPregnancyDay: UIButton!
    @IBOutlet var userPregnancyWeek: UIButton!
    @IBOutlet var userTrimester: UIButton!
    @IBOutlet var userPhoneNumber: UIButton!
    
    var isEditingMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        updateElements()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))
        tableView.delegate = self
        tableView.dataSource = self
        
    }

    @objc func toggleEditMode() {
        isEditingMode.toggle()
        
        navigationItem.rightBarButtonItem?.title = isEditingMode ? "Save" : "Edit"
        updateUIForEditingMode()
        
        tableView.reloadData()
    }
    
    @objc func editTapped() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        if tableView.isEditing {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editTapped))
        }
        else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))
        }
    }
    
    func updateUIForEditingMode(){
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
        
//        saveButton.isHidden = !isEditingMode
    }
    
    func calculateAge(from dob: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: dob, to: now)
        return ageComponents.year ?? 0
    }
        
    func updateElements(){
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
    

}
