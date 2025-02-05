//
//  SignUpDetailsTableViewController.swift
//  MomCare
//
//  Created by Batch-2 on 15/01/25.
//

import UIKit

class SignUpDetailsTableViewController: UITableViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet var dateOfBirthPicker: UIDatePicker!
    @IBOutlet var heightLabel: UILabel!
    @IBOutlet var prePregnancyWeightLabel: UILabel!
    @IBOutlet var currentWeightLabel: UILabel!
    @IBOutlet var countryLabel: UILabel!

    var height: Int = 0
    var prePregnancyWeight: Int = 0
    var currentWeight: Int = 0

    var pickerOption: PickerOptions?

    @IBOutlet var progressView: UIProgressView!

    var initialProgress: Float = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.progress = initialProgress
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.progressView.setProgress(0.5, animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "segueShowSignUpExtendedTableViewController":
            if let destinationTableViewController = segue.destination as? SignUpExtendedTableViewController {
                destinationTableViewController.initialProgress = progressView.progress
                destinationTableViewController.signUpDetailsTableViewController = self
            }

        default:
            if let destination = segue.destination as? PickerViewController, let presentationController = destination.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium()]
                present(destination, animated: true)
            }
        }
    }

    @IBAction func unwindToSignUp(_ segue: UIStoryboardSegue) {}

    @IBSegueAction func segueViaHeightButton(_ coder: NSCoder) -> PickerViewController? {
        return PickerViewController(coder: coder, with: .height, sender: self)
    }

    @IBSegueAction func segueViaPrePregnancyButton(_ coder: NSCoder) -> PickerViewController? {
        return PickerViewController(coder: coder, with: .prePregnancyWeight, sender: self)
    }

    @IBSegueAction func segueViaWeightButton(_ coder: NSCoder) -> PickerViewController? {
        return PickerViewController(coder: coder, with: .currentWeight, sender: self)
    }

    @IBSegueAction func segueViaCountryButton(_ coder: NSCoder) -> PickerViewController? {
        return PickerViewController(coder: coder, with: .country, sender: self)
    }
}
