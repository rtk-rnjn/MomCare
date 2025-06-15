//
//  SignUpExtendedTableViewController.swift
//  MomCare
//
//  Created by Nupur on 14/01/25.
//

import UIKit

class SignUpExtendedTableViewController: UITableViewController {

    // MARK: Internal

    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var dueDatePicker: UIDatePicker!

    var initialProgress: Float = 0.0
    var userMedical: UserMedical?
    var multipleSelectorTableViewController: MultipleSelectorTableViewController?

    var intolerances: [String] = []
    var preExistingConditions: [String] = []
    var dietaryPreferences: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.progress = initialProgress
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.progressView.setProgress(1.0, animated: true)
        }

        let calendar = Calendar.current
        let today = Date()
        let minDueDate = calendar.date(byAdding: .day, value: 7, to: today)!
        let maxDueDate = calendar.date(byAdding: .day, value: 280, to: today)!

        dueDatePicker.minimumDate = minDueDate
        dueDatePicker.maximumDate = maxDueDate
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UINavigationController, let presentationController = destination.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium()]
            if let medicalDetailSelectorTableViewController = destination.viewControllers.first as? MultipleSelectorTableViewController {
                guard let sender = sender as? (options: [String], dismissHandler: () -> Void) else { return }
                medicalDetailSelectorTableViewController.dismissHandler = sender.dismissHandler
                medicalDetailSelectorTableViewController.options = sender.options
            }
        }
    }

    @IBAction func finishButtonTapped(_ sender: UIButton) {
        let dueDate = dueDatePicker.date

        guard var userMedical else { fatalError() }

//        userMedical.dueDate = dueDate
//        userMedical.foodIntolerances = intolerances
//        userMedical.preExistingConditions = preExistingConditions
//        userMedical.dietaryPreferences = dietaryPreferences

        Task {
            await handleSignUpExtended(userMedical: userMedical)
        }
    }

    @IBAction func intoleranceButtonTapped(_ sender: UIButton) {
        presentMedicalDetailSelector(
            sender: sender,
            options: Intolerance.allCases.map { $0.rawValue },
            assignTo: { self.intolerances = $0 }
        )
    }

    @IBAction func preExistingConditionTapped(_ sender: UIButton) {
        presentMedicalDetailSelector(
            sender: sender,
            options: PreExistingCondition.allCases.map { $0.rawValue },
            assignTo: { self.preExistingConditions = $0 }
        )
    }

    @IBAction func dietaryPreferenceTapped(_ sender: UIButton) {
        presentMedicalDetailSelector(
            sender: sender,
            options: DietaryPreference.allCases.map { $0.rawValue },
            assignTo: { self.dietaryPreferences = $0 }
        )
    }

    @IBAction func unwinToMedicalDetail(_ segue: UIStoryboardSegue) {
        multipleSelectorTableViewController?.dismissHandler?()
    }

    // MARK: Private

    private func presentMedicalDetailSelector(
        sender: UIButton,
        options: [String],
        assignTo: @escaping ([String]) -> Void
    ) {
        let dismissHandler: () -> Void = {
            let count = self.multipleSelectorTableViewController?.selectedMappedOptions.count ?? 0
            let labelText = count == 0 ? "None" : "\(count) selected"
            sender.setTitle(labelText, for: .normal)
            let selectedMappedOptions: [String: Bool] = self.multipleSelectorTableViewController?.selectedMappedOptions ?? [:]
            let selectedValues = selectedMappedOptions.filter { $0.value }.map { $0.key }
            assignTo(selectedValues)
        }
        performSegue(withIdentifier: "segueShowMedicalDetailSelectorTableViewController", sender: (options, dismissHandler))
    }

    private func handleSignUpExtended(userMedical: UserMedical) async {
        let success = await MomCareUser.shared.updateUserMedical(userMedical)
        DispatchQueue.main.async {
            if !success {
                let alert = Utils.getAlert(title: "Error", message: "Failed to update medical data. Please try again.")
                self.present(alert, animated: true)
                return
            } else {
                Utils.save(forKey: "isUserSignedUp", withValue: true)
                self.performSegue(withIdentifier: "segueShowInitialTabBarController", sender: nil)
            }
        }
    }

}
