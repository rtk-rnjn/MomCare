//
//  SignUpTableViewController.swift
//  MomCare
//
//  Created by Batch-2 on 10/01/25.
//

import UIKit

class SignUpTableViewController: UITableViewController {

    // MARK: Internal

    @IBOutlet var createButton: UIButton!

    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!

    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var confirmPasswordField: UITextField!

    @IBOutlet var countryCodeField: UITextField!
    @IBOutlet var mobileNumberField: UITextField!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowPickerViewController", let destination = segue.destination as? PickerViewController, let presentationController = destination.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium()]

            destination.options = sender as? [String: String]
            destination.completionHandler = { key, _ in
                self.countryCodeField.text = key
            }
        }
    }

    @IBAction func createButtonTapped(_ sender: UIButton) {
        // swiftlint:disable large_tuple
        let requiredFields: [(UITextField, String, String)] = [
            (firstNameField, "First Name Required", "Please enter your first name."),
            (emailField, "Email Required", "Please enter your email."),
            (passwordField, "Password Required", "Please enter your password."),
            (confirmPasswordField, "Confirm Password Required", "Please confirm your password."),
            (countryCodeField, "Country Code Required", "Please enter your country code."),
            (mobileNumberField, "Mobile Number Required", "Please enter your mobile number.")
        ]
        // swiftlint:enable large_tuple

        var errors: [[String]] = []

        for (field, title, message) in requiredFields where (field.text ?? "").isEmpty {
            errors.append([title, message])
        }

        if let password = passwordField.text, let confirmPassword = confirmPasswordField.text, password != confirmPassword {
            errors.append(["Passwords Do Not Match", "Please ensure your passwords match."])
        }

        if !errors.isEmpty {
            createErrorAlert(with: errors)
            return
        }

        let user = User(
            firstName: firstNameField.text!,
            lastName: lastNameField.text,
            emailAddress: emailField.text!,
            password: passwordField.text!,
            countryCode: countryCodeField.text ?? "+91",
            phoneNumber: mobileNumberField.text!
        )

        Task {
            DispatchQueue.main.async {
                self.showActivityIndicator()
            }
            var userCreated = false
            userCreated = await MomCareUser.shared.createNewUser(user)

            DispatchQueue.main.async {
                self.hideActivityIndicator()
                if !userCreated {
                    self.showErrorAlert(title: "User Creation Failed", message: "An error occurred while creating your account. Please try again.")
                } else {
                    self.performSegue(withIdentifier: "segueShowSignUpDetailsTableViewController", sender: nil)
                }
            }
        }
    }

    @IBAction func editingChanged(_ sender: UITextField) {}

    @IBAction func countryCodeFieldTapped(_ sender: UITextField) {
        performSegue(withIdentifier: "segueShowPickerViewController", sender: CountryData.countryCodes)
    }

    @IBAction func unwindToSignUp(_ segue: UIStoryboardSegue) {}

    // MARK: Private

    private var activityIndicator: UIActivityIndicatorView?

    private func createErrorAlert(with errors: [[String]]) {
        let title = errors.count == 1 ? errors[0][0] : "Errors"

        var message: String

        if errors.count == 1 {
            message = "\(errors[0][0]): \(errors[0][1])"
        } else {
            message = errors.map { "\($0[0])" }.joined(separator: "\n")
        }

        showErrorAlert(title: title, message: message)
    }

    private func showErrorAlert(title: String, message: String) {
        let alert = Utils.getAlert(title: title, message: message, actions: [AlertActionHandler(title: "OK", style: .default, handler: nil)])
        present(alert, animated: true)
    }

    private func showActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)

        guard let activityIndicator else { fatalError("ek ajnabi haseea se, yu mulakat ho gai") }
        activityIndicator.center = tableView.center
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true

        view.addSubview(activityIndicator)
    }

    private func hideActivityIndicator() {
        guard let activityIndicator else { fatalError("fir kya hua, yeh na poocho. kuch aisi baat ho gai") }
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }

}
