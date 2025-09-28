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
        navigationController?.navigationBar.tintColor = .CustomColors.mutedRaspberry
        updatePageElements()
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
    }

    func updatePageElements() {
        guard let userMedical = MomCareUser.shared.user?.medicalData else { return }

        userDueDate.date = userMedical.dueDate!
        userMedicalConditions.setTitle("\(userMedical.preExistingConditions.count)", for: .normal)
        userDietaryPreferences.setTitle("\(userMedical.dietaryPreferences.count)", for: .normal)
        userAllergies.setTitle("\(userMedical.foodIntolerances.count)", for: .normal)
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
