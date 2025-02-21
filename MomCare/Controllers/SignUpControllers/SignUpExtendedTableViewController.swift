//
//  SignUpExtendedTableViewController.swift
//  MomCare
//
//  Created by Nupur on 14/01/25.
//

import UIKit

class SignUpExtendedTableViewController: UITableViewController {

    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var dueDatePicker: UIDatePicker!

    var initialProgress: Float = 0.0
    var userMedical: UserMedical?

    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.progress = initialProgress
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.progressView.setProgress(1.0, animated: true)
        }

        dueDatePicker.minimumDate = Date()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UINavigationController, let presentationController = destination.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium()]
            if let medicalDetailSelectorTableViewController = destination.viewControllers.first as? MultipleSelectorTableViewController {
                medicalDetailSelectorTableViewController.options = sender as? [String] ?? []
            }
        }
    }

    @IBAction func finishButtonTapped(_ sender: UIButton) {
        let dueDate = dueDatePicker.date

        userMedical?.dueDate = dueDate
        MomCareUser.shared.user?.medicalData = userMedical

        Utils.save(forKey: .signedUp, withValue: true)

        performSegue(withIdentifier: "segueShowInitialTabBarController", sender: nil)
    }

    @IBAction func intoleranceButtonTapped(_ sender: Any) {
        let options = Intolerance.allCases.map { $0.rawValue }
        performSegue(withIdentifier: "segueShowMedicalDetailSelectorTableViewController", sender: options)
    }

    @IBAction func preExistingConditionTapped(_ sender: Any) {
        let options = PreExistingCondition.allCases.map { $0.rawValue }
        performSegue(withIdentifier: "segueShowMedicalDetailSelectorTableViewController", sender: options)
    }

    @IBAction func dietaryPreferenceTapped(_ sender: Any) {
        let options = DietaryPreference.allCases.map { $0.rawValue }
        performSegue(withIdentifier: "segueShowMedicalDetailSelectorTableViewController", sender: options)
    }

    @IBAction func unwinToMedicalDetail(_ segue: UIStoryboardSegue) {}
}
