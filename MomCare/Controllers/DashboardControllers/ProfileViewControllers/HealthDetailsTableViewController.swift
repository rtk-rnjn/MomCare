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
        navigationController?.navigationBar.tintColor = UIColor(hex: "#924350")
        updatePageElements()
        setupAccessibility()
    }
    
    private func setupAccessibility() {
        // Set up accessibility for the date picker
        userDueDate.accessibilityLabel = "Due date"
        userDueDate.accessibilityHint = "Select your pregnancy due date"
        
        // Set up accessibility for the buttons
        userMedicalConditions.accessibilityLabel = "Medical conditions"
        userMedicalConditions.accessibilityHint = "Tap to select your pre-existing medical conditions"
        
        userDietaryPreferences.accessibilityLabel = "Dietary preferences"
        userDietaryPreferences.accessibilityHint = "Tap to select your dietary preferences"
        
        userAllergies.accessibilityLabel = "Food allergies and intolerances"
        userAllergies.accessibilityHint = "Tap to select your food allergies and intolerances"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowMultipleSelectorTableViewController", let destination = segue.destination as? MultipleSelectorTableViewController {
            if let sender = sender as? (options: [String], button: UIButton, category: HealthProfileType) { // swiftlint:disable:this large_tuple
                destination.options = sender.options

                switch sender.category {
                case .dietaryPreference:
                    let selectedOptions: [String: Bool] = (MomCareUser.shared.user?.medicalData?.dietaryPreferences ?? []).reduce(into: [String: Bool]()) { dict, preference in
                        dict[preference.rawValue] = true
                    }

                    destination.preViewDidLoad = preViewDidLoad
                    destination.selectedMappedOptions = selectedOptions
                    destination.dismissHandler = {
                        MomCareUser.shared.user?.medicalData?.dietaryPreferences = destination.selectedMappedOptions.filter { $1 }.keys.compactMap(DietaryPreference.init(rawValue:))
                        self.updatePageElements()
                    }

                case .intolerance:
                    let selectedOptions: [String: Bool] = (MomCareUser.shared.user?.medicalData?.foodIntolerances ?? []).reduce(into: [String: Bool]()) { dict, preference in
                        dict[preference.rawValue] = true
                    }

                    destination.preViewDidLoad = preViewDidLoad
                    destination.selectedMappedOptions = selectedOptions
                    destination.dismissHandler = {
                        MomCareUser.shared.user?.medicalData?.foodIntolerances = destination.selectedMappedOptions.filter { $1 }.keys.compactMap(Intolerance.init(rawValue:))
                        self.updatePageElements()
                    }

                case .preExistingCondition:
                    let selectedOptions: [String: Bool] = (MomCareUser.shared.user?.medicalData?.preExistingConditions ?? []).reduce(into: [String: Bool]()) { dict, preference in
                        dict[preference.rawValue] = true
                    }

                    destination.preViewDidLoad = preViewDidLoad
                    destination.selectedMappedOptions = selectedOptions
                    destination.dismissHandler = {
                        MomCareUser.shared.user?.medicalData?.preExistingConditions = destination.selectedMappedOptions.filter { $1 }.keys.compactMap(PreExistingCondition.init(rawValue:))
                        self.updatePageElements()
                    }
                }

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
        
        // Update accessibility hints based on editing mode
        if isEditingMode {
            userDueDate.accessibilityHint = "Swipe up or down to change the due date"
            userMedicalConditions.accessibilityHint = "Tap to select your pre-existing medical conditions"
            userDietaryPreferences.accessibilityHint = "Tap to select your dietary preferences"
            userAllergies.accessibilityHint = "Tap to select your food allergies and intolerances"
        } else {
            userDueDate.accessibilityHint = "Your pregnancy due date. Tap edit to change."
            userMedicalConditions.accessibilityHint = "Your medical conditions. Tap edit to change."
            userDietaryPreferences.accessibilityHint = "Your dietary preferences. Tap edit to change."
            userAllergies.accessibilityHint = "Your food allergies. Tap edit to change."
        }
    }

    func updatePageElements() {
        guard let userMedical = MomCareUser.shared.user?.medicalData else { return }

        userDueDate.date = userMedical.dueDate!
        
        // Update button titles and accessibility values
        let conditionsCount = userMedical.preExistingConditions.count
        userMedicalConditions.setTitle("\(conditionsCount)", for: .normal)
        userMedicalConditions.accessibilityValue = conditionsCount == 0 ? "No conditions selected" : "\(conditionsCount) conditions selected"
        
        let preferencesCount = userMedical.dietaryPreferences.count
        userDietaryPreferences.setTitle("\(preferencesCount)", for: .normal)
        userDietaryPreferences.accessibilityValue = preferencesCount == 0 ? "No preferences selected" : "\(preferencesCount) preferences selected"
        
        let intolerancesCount = userMedical.foodIntolerances.count
        userAllergies.setTitle("\(intolerancesCount)", for: .normal)
        userAllergies.accessibilityValue = intolerancesCount == 0 ? "No allergies selected" : "\(intolerancesCount) allergies selected"
    }

    func saveHealthDetails() {}

    @IBAction func preExistingTapped(_ sender: UIButton) {
        let options = PreExistingCondition.allCases.map { $0.rawValue }
        let button = sender
        let category = HealthProfileType.preExistingCondition
        let sendable = (options: options, button: button, category: category)

        performSegue(withIdentifier: "segueShowMultipleSelectorTableViewController", sender: sendable)
    }

    @IBAction func intoleranceTapped(_ sender: UIButton) {
        let options = Intolerance.allCases.map { $0.rawValue }
        let button = sender
        let category = HealthProfileType.intolerance

        let sendable = (options: options, button: button, category: category)

        performSegue(withIdentifier: "segueShowMultipleSelectorTableViewController", sender: sendable)
    }

    @IBAction func dietaryTapped(_ sender: UIButton) {
        let options = DietaryPreference.allCases.map { $0.rawValue }
        let button = sender
        let category = HealthProfileType.dietaryPreference

        let sendable = (options: options, button: button, category: category)

        performSegue(withIdentifier: "segueShowMultipleSelectorTableViewController", sender: sendable)
    }

    func preViewDidLoad(viewController: UIViewController) {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )

        viewController.navigationItem.leftBarButtonItem = backButton
        viewController.navigationItem.rightBarButtonItem = nil
    }

    @objc func backButtonTapped() {
        if let topViewController = navigationController?.topViewController as? MultipleSelectorTableViewController {
            topViewController.dismissHandler?()
        }
        navigationController?.popViewController(animated: true)
    }
}
