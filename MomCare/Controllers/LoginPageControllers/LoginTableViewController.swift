import UIKit

class LoginTableViewController: UITableViewController, UITextFieldDelegate {

    // MARK: Internal

    @IBOutlet var emailAddressField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var signInButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        emailAddressField.delegate = self
        passwordField.delegate = self

        emailAddressField.becomeFirstResponder()
        navigationController?.navigationBar.tintColor = UIColor(hex: "#924350")
        setupAccessibility()
    }
    
    private func setupAccessibility() {
        setupBasicAccessibility(title: "Sign In")
        
        setupFormAccessibilityForTextFields(fields: [
            (textField: emailAddressField, label: "Email address", hint: "Enter your email address to sign in"),
            (textField: passwordField, label: "Password", hint: "Enter your password")
        ])
        
        setupButtonAccessibilityWithMinimumTouchTargets(buttons: [
            (button: signInButton, label: "Sign In", hint: "Tap to sign in to your MomCare account")
        ])
        
        emailAddressField.textContentType = .emailAddress
        emailAddressField.keyboardType = .emailAddress
        emailAddressField.autocapitalizationType = .none
        
        passwordField.textContentType = .password
        passwordField.isSecureTextEntry = true
        
        emailAddressField.adjustsFontForContentSizeCategory = true
        passwordField.adjustsFontForContentSizeCategory = true
        
        validateColorContrast()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowOTPScreenViewController", let destinationVC = segue.destination as? OTPScreenViewController {
            let data = sender as? (email: String, password: String)
            destinationVC.emailAddress = data?.email
            destinationVC.password = data?.password
            destinationVC.segueIdentifier = "segueShowInitialTabBarController"
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailAddressField {
            passwordField.becomeFirstResponder()
            return false
        }
        if textField == passwordField {
            signInButtonTapped(signInButton)
            return false
        }
        return true
    }

    @IBAction func textFieldChanged(_ sender: UITextField) {}

    @IBAction func signInButtonTapped(_ sender: UIButton) {
        // swiftlint:disable large_tuple
        view.endEditing(true)

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

            let success = await MomCareUser.shared.loginUser(email: email, password: password)
            DispatchQueue.main.async {
                sender.stopLoadingAnimation(withRestoreLabel: "Sign In")
            }
            if !success {
                self.showErrorAlert(title: "Sign In Failed", message: "An error occurred while signing in. Please try again.")
            } else {
                performSegue(withIdentifier: "segueShowOTPScreenViewController", sender: (email: email, password: password))
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
