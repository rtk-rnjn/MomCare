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
                guard let sender = sender as? (options: [String], button: UIButton) else { return }
                medicalDetailSelectorTableViewController.options = sender.options
                medicalDetailSelectorTableViewController.button = sender.button
            }
        }
    }

    @IBAction func finishButtonTapped(_ sender: UIButton) {
        let dueDate = dueDatePicker.date

        guard var userMedical else { fatalError() }

        userMedical.dueDate = dueDate
        Task {
            await handleSignUpExtended(userMedical: userMedical)
        }
    }

    @IBAction func intoleranceButtonTapped(_ sender: UIButton) {
        let options = Intolerance.allCases.map { $0.rawValue }
        performSegue(withIdentifier: "segueShowMedicalDetailSelectorTableViewController", sender: (options, sender))
    }

    @IBAction func preExistingConditionTapped(_ sender: UIButton) {
        let options = PreExistingCondition.allCases.map { $0.rawValue }
        performSegue(withIdentifier: "segueShowMedicalDetailSelectorTableViewController", sender: (options, sender))
    }

    @IBAction func dietaryPreferenceTapped(_ sender: UIButton) {
        let options = DietaryPreference.allCases.map { $0.rawValue }
        performSegue(withIdentifier: "segueShowMedicalDetailSelectorTableViewController", sender: (options, sender))
    }

    @IBAction func unwinToMedicalDetail(_ segue: UIStoryboardSegue) {}

    // MARK: Private

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
