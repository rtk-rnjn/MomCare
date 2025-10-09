//
//  SignUpDetailsTableViewController.swift
//  MomCare
//
//  Created by Batch-2 on 15/01/25.
//

import UIKit

class SignUpDetailsTableViewController: UITableViewController, UIViewControllerTransitioningDelegate {

    // MARK: Internal

    @IBOutlet var dateOfBirthPicker: UIDatePicker!

    @IBOutlet var heightButton: UIButton!
    @IBOutlet var prePregnancyWeightButton: UIButton!
    @IBOutlet var currentWeightButton: UIButton!
    @IBOutlet var countryButton: UIButton!

    var height: Int?
    var prePregnancyWeight: Int?
    var currentWeight: Int?
    var country: String?

    @IBOutlet var progressView: UIProgressView!

    var initialProgress: Float = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.progress = initialProgress
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.progressView.setProgress(0.5, animated: true)
        }

        let calendar = Calendar.current
        let today = Date()
        let eighteenYearsAgo = calendar.date(byAdding: .year, value: -18, to: today)!

        dateOfBirthPicker.maximumDate = eighteenYearsAgo
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "segueShowSignUpExtendedTableViewController":
            if let destinationTableViewController = segue.destination as? SignUpExtendedTableViewController {
                destinationTableViewController.initialProgress = progressView.progress

                guard let medical = sender as? UserMedical else { fatalError("UserMedical not set") }
                destinationTableViewController.userMedical = medical
            }

        case "segueShowPickerViewController":
            if let destination = segue.destination as? PickerViewController, let presentationController = destination.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium()]

                let sender = sender as? (options: [String: String], completionHandler: (String, String) -> Void)
                guard let sender else { fatalError("Sender not set") }

                destination.options = sender.options
                destination.completionHandler = sender.completionHandler
            }

        default:
            fatalError("Unknown segue")
        }
    }

    @IBAction func unwindToSignUp(_ segue: UIStoryboardSegue) {}

    @IBAction func heightButtonTapped(_ sender: UIButton) {
        let heights: [String: String] = Array(120...220).reduce(into: [:]) { $0["\($1)"] = "\($1) cm" }
        var completionHandler: ((String, String) -> Void)?
        completionHandler = { key, value in
            self.height = Int(key)!
            self.heightButton.setTitle(value, for: .normal)
        }

        let sendable = (options: heights, completionHandler: completionHandler)
        performSegue(withIdentifier: "segueShowPickerViewController", sender: sendable)
    }

    @IBAction func prePregnacyWeightButtonTapped(_ sender: UIButton) {
        let weights: [String: String] = Array(40...120).reduce(into: [:]) { $0["\($1)"] = "\($1) kg" }
        var completionHandler: ((String, String) -> Void)?
        completionHandler = { key, value in
            self.prePregnancyWeight = Int(key)!
            self.prePregnancyWeightButton.setTitle(value, for: .normal)
        }

        let sendable = (options: weights, completionHandler: completionHandler)
        performSegue(withIdentifier: "segueShowPickerViewController", sender: sendable)
    }

    @IBAction func currentWeightButtonTapped(_ sender: UIButton) {
        let weights: [String: String] = Array(40...120).reduce(into: [:]) { $0["\($1)"] = "\($1) kg" }
        var completionHandler: ((String, String) -> Void)?
        completionHandler = { key, value in
            self.currentWeight = Int(key)!
            self.currentWeightButton.setTitle(value, for: .normal)
        }

        let sendable = (options: weights, completionHandler: completionHandler)
        performSegue(withIdentifier: "segueShowPickerViewController", sender: sendable)
    }

    @IBAction func countryButtonTapped(_ sender: UIButton) {
        let countries = CountryData.countryCodes.reduce(into: [:]) { $0[$1.key] = $1.value }
        var completionHandler: ((String, String) -> Void)?
        completionHandler = { key, value in
            self.country = key
            self.countryButton.setTitle(value, for: .normal)
        }

        let sendable = (options: countries, completionHandler: completionHandler)
        performSegue(withIdentifier: "segueShowPickerViewController", sender: sendable)
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        var errors = [(String, String)]()
        if height == nil {
            errors.append(("Height", "Please select your height"))
        }
        if prePregnancyWeight == nil {
            errors.append(("Pre-pregnancy weight", "Please select your pre-pregnancy weight"))
        }
        if currentWeight == nil {
            errors.append(("Current weight", "Please select your current weight"))
        }
        if country == nil {
            errors.append(("Country", "Please select your country"))
        }

        if !errors.isEmpty {
            createErrorAlert(with: errors)
            return
        }

        let userMedical = UserMedical(dateOfBirth: dateOfBirthPicker.date, height: Double(height!), prePregnancyWeight: Double(prePregnancyWeight!), currentWeight: Double(currentWeight!))

        performSegue(withIdentifier: "segueShowSignUpExtendedTableViewController", sender: userMedical)
    }

    // MARK: Private

    private func createErrorAlert(with errors: [(String, String)]) {
        let alert = Utils.getAlert(title: "Errors", message: errors.map { "\($0.0): \($0.1)" }.joined(separator: "\n"), actions: [AlertActionHandler(title: "OK", style: .default, handler: nil)])
        present(alert, animated: true, completion: nil)
    }
}
