//
//  SignUpTableViewController.swift
//  MomCare
//
//  Created by Batch-2 on 10/01/25.
//

import UIKit

class SignUpTableViewController: UITableViewController {

    @IBOutlet var createButton: UIButton!

    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!

    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var confirmPasswordField: UITextField!

    @IBOutlet var countryCodeField: UITextField!
    @IBOutlet var mobileNumberField: UITextField!

    @IBAction func createButtonTapped(_ sender: UIButton) {
        guard let firstName = firstNameField.text, !firstName.isEmpty else {
            createErrorAlert(title: "First Name Required", message: "Please enter your first name.")
            return
        }

        guard let email = emailField.text, !email.isEmpty else {
            createErrorAlert(title: "Email Required", message: "Please enter your email.")
            return
        }

        guard let password = passwordField.text, !password.isEmpty else {
            createErrorAlert(title: "Password Required", message: "Please enter your password.")
            return
        }

        guard let confirmPassword = confirmPasswordField.text, !confirmPassword.isEmpty else {
            createErrorAlert(title: "Confirm Password Required", message: "Please confirm your password.")
            return
        }

        guard let password = passwordField.text, let confirmPassword = confirmPasswordField.text, password == confirmPassword else {
            createErrorAlert(title: "Passwords Do Not Match", message: "Please make sure your passwords match.")
            return
        }

        guard let countryCode = countryCodeField.text, !countryCode.isEmpty else {
            createErrorAlert(title: "Country Code Required", message: "Please enter your country code.")
            return
        }

        guard let mobileNumber = mobileNumberField.text, !mobileNumber.isEmpty else {
            createErrorAlert(title: "Mobile Number Required", message: "Please enter your mobile number.")
            return
        }
    }

    @IBAction func editingChanged(_ sender: UITextField) {
    }

    @IBAction func countryCodeFieldTapped(_ sender: UITextField) {
        performSegue(withIdentifier: "segueShowPickerViewController", sender: nil)
    }
    
    @IBSegueAction func segueViaCountryCodeField(_ coder: NSCoder) -> PickerViewController? {
        return PickerViewController(coder: coder, with: countryCodeField, sender: self)
    }
    
    private func createErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowPickerViewController", let destination = segue.destination as? PickerViewController, let presentationController = destination.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium()]
            present(destination, animated: true)
        }
    }

    @IBAction func unwindToSignUp(_ segue: UIStoryboardSegue) {
    }
}
