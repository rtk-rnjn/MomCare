import UIKit

class LoginTableViewController: UITableViewController {

    // MARK: Internal

    @IBOutlet var emailAddressField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var signInButton: UIButton!

    @IBAction func textFieldChanged(_ sender: UITextField) {}

    @IBAction func signInButtonTapped(_ sender: UIButton) {
        // swiftlint:disable large_tuple
        let requiredFields: [(UITextField, String, String)] = [
            (emailAddressField, "Email Required", "Please enter your email."),
            (passwordField, "Password Required", "Please enter your password.")
        ]
        // swiftlint:enable large_tuple

        var errors: [[String]] = []

        for (field, title, message) in requiredFields where (field.text ?? "").isEmpty {
            errors.append([title, message])
        }

        if !errors.isEmpty {
            createErrorAlert(with: errors)
            return
        }

        guard let email = emailAddressField.text, let password = passwordField.text else { return }

        Task {
            DispatchQueue.main.async {
                sender.startLoadingAnimation()
            }

            let success = await MomCareUser.shared.fetchUserFromDatabase(with: email, and: password)
            if !success {
                DispatchQueue.main.async {
                    sender.stopLoadingAnimation(with: "Sign In")
                }

                self.showErrorAlert(title: "Sign In Failed", message: "An error occurred while signing in. Please try again.")
            } else {
                if MomCareUser.shared.user?.medicalData == nil {
                    performSegue(withIdentifier: "segueShowSignUpDetailsTableViewController", sender: nil)
                } else {
                    performSegue(withIdentifier: "segueShowInitialTabBarController", sender: nil)
                }
            }
        }
    }

    // MARK: Private

    // From: MomCare/MomCare/Controllers/SignUpCotrollers/SignUpTableViewController.swift

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
}
