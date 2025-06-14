//
//  HealthDetailsTableViewController.swift
//  MomCare
//
//  Created by Khushi Rana on 12/06/25.
//

import UIKit

class HealthDetailsTableViewController: UITableViewController {

    @IBOutlet var userDueDate: UIDatePicker!
    @IBOutlet var userMedicalConditions: UIButton!
    @IBOutlet var userDietaryPreferences: UIButton!
    @IBOutlet var userAllergies: UIButton!

    var isEditingMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        updatePageElements()
        
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        isEditingMode.toggle()
        sender.title = isEditingMode ? "Save" : "Edit"
        toggleEditMode()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUserHealthProfile",
           let destination = segue.destination as? HealthDetailsCellTableViewController,
           let type = sender as? HealthProfileType {
            destination.healthProfile = type
        }
    }

    func toggleEditMode() {
        updateUIForEditingMode()
        
        if !isEditingMode {
            Task{
                saveUser()
            }
        }
    }
    
    func saveUser(){
        MomCareUser.shared.user?.medicalData?.dueDate = userDueDate.date
    }

    func updateUIForEditingMode() {
        userDueDate.isUserInteractionEnabled = isEditingMode
        userMedicalConditions.isUserInteractionEnabled = isEditingMode
        userDietaryPreferences.isUserInteractionEnabled = isEditingMode
        userAllergies.isUserInteractionEnabled = isEditingMode
    }

    func updatePageElements() {
        guard let userMedical = MomCareUser.shared.user?.medicalData else { return }

        userDueDate.date = userMedical.dueDate!
        userMedicalConditions.setTitle("\(userMedical.preExistingConditions.count)", for: .normal)
        userDietaryPreferences.setTitle("\(userMedical.dietaryPreferences.count)", for: .normal)
        userAllergies.setTitle("\(userMedical.foodIntolerances.count)", for: .normal)
    }

    func saveHealtghDetails() {}

    @IBAction func preExistingTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showUserHealthProfile", sender: HealthProfileType.preExistingCondition)
    }

    @IBAction func intoleranceTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showUserHealthProfile", sender: HealthProfileType.intolerance)
    }

    @IBAction func dietaryTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showUserHealthProfile", sender: HealthProfileType.dietaryPreference)
    }

}
