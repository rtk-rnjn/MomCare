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
    var multipleSelectorTableViewController: MultipleSelectorTableViewController?

    var intolerances: [String] = .init()
    var preExistingConditions: [String] = .init()
    var dietaryPreferences: [String] = .init()

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

                multipleSelectorTableViewController = medicalDetailSelectorTableViewController
            }
        }
    }

    @IBAction func finishButtonTapped(_ sender: UIButton) {
        let dueDate = dueDatePicker.date

        MomCareUser.shared.user?.dueDateTimestamp = dueDate.timeIntervalSince1970
        MomCareUser.shared.user?.foodIntolerances = intolerances.map({ Intolerance(rawValue: $0) ?? .none })
        MomCareUser.shared.user?.preExistingConditions = preExistingConditions.map({ PreExistingCondition(rawValue: $0) ?? .none })
        MomCareUser.shared.user?.dietaryPreferences = dietaryPreferences.map({ DietaryPreference(rawValue: $0) ?? .none })

        handleSignUpExtended()
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
            let selectedMappedOptions: [String: Bool] = self.multipleSelectorTableViewController?.selectedMappedOptions ?? [:]
            let selectedValues = selectedMappedOptions.filter { $0.value }.map { $0.key }
            let count = selectedValues.count

            let labelText = count == 0 ? "None" : "\(count) selected"
            sender.setTitle(labelText, for: .normal)

            assignTo(selectedValues)
        }
        performSegue(withIdentifier: "segueShowMedicalDetailSelectorTableViewController", sender: (options, dismissHandler))
    }

    private func handleSignUpExtended() {
        Utils.save(forKey: "isUserSignedUp", withValue: true)
        performSegue(withIdentifier: "segueShowInitialTabBarController", sender: nil)
    }

}
