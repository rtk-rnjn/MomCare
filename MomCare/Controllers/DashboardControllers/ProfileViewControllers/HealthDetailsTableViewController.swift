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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUserHealthProfile", let destination = segue.destination as? HealthDetailsCellTableViewController, let type = sender as? HealthProfileType {
            destination.healthProfile = type

            switch type {
            case .dietaryPreference:
                destination.selectedCells = MomCareUser.shared.user?.medicalData?.dietaryPreferences.map { $0.rawValue } ?? []
            case .intolerance:
                destination.selectedCells = MomCareUser.shared.user?.medicalData?.foodIntolerances.map { $0.rawValue } ?? []
            case .preExistingCondition:
                destination.selectedCells = MomCareUser.shared.user?.medicalData?.preExistingConditions.map { $0.rawValue } ?? []
            }

            destination.onSelection = { [weak self] profileType, selectedItems in
                switch profileType {
                case .dietaryPreference:
                    MomCareUser.shared.user?.medicalData?.dietaryPreferences = selectedItems.map({ DietaryPreference(rawValue: $0) ?? .none })
                case .intolerance:
                    MomCareUser.shared.user?.medicalData?.foodIntolerances = selectedItems.map({ Intolerance(rawValue: $0) ?? .none })
                case .preExistingCondition:
                    MomCareUser.shared.user?.medicalData?.preExistingConditions = selectedItems.map({ PreExistingCondition(rawValue: $0) ?? .none })
                }

                self?.updatePageElements()
            }
        }
    }

    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        isEditingMode.toggle()
        sender.title = isEditingMode ? "Save" : "Edit"
        toggleEditMode()
    }

    func toggleEditMode() {
        updateUIForEditingMode()

        if !isEditingMode {
            MomCareUser.shared.user?.medicalData?.dueDate = userDueDate.date
        }
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
