//
//  SettingsTableViewController.swift
//  MomCare
//
//  Created by Aryan Singh on 13/06/25.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var oldPasswordField: UITextField!
    @IBOutlet var newPasswordField: UITextField!
    @IBOutlet var confirmPasswordField: UITextField!
    @IBOutlet var changePasswordButton: UIButton!

    var isPasswordFieldsVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        updatePageElements()
        navigationController?.navigationBar.tintColor = UIColor(hex: "#924350")
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            isPasswordFieldsVisible.toggle()

            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 && [0, 1, 2, 3].contains(indexPath.row) {
            return isPasswordFieldsVisible ? UITableView.automaticDimension : 0
        }
        return UITableView.automaticDimension
    }

    func updatePageElements() {
        guard let user = MomCareUser.shared.user else { return }
        emailLabel.text = user.emailAddress
        phoneNumberLabel.text = user.phoneNumber
    }

    @IBAction func changeButtonTapped(_ sender: UIButton) {
        guard let oldPassword = oldPasswordField.text,
              let newPassword = newPasswordField.text,
              let confirmPassowrd = confirmPasswordField.text else {
            return
        }

        guard !oldPassword.isEmpty && !newPassword.isEmpty && !confirmPassowrd.isEmpty else {
            showAlert(title: "Error", message: "Please fill all fields")
            return
        }

        guard oldPassword == MomCareUser.shared.user?.password else {
            showAlert(title: "Error", message: "Current password is incorrect")
            return
        }

        guard newPassword == confirmPassowrd else {
            showAlert(title: "Error", message: "Passwords do not match")
            return
        }

        MomCareUser.shared.user?.password = newPassword
        showAlert(title: "Success", message: "Password changed!") {
            self.oldPasswordField.text = ""
            self.newPasswordField.text = ""
            self.confirmPasswordField.text = ""

            self.isPasswordFieldsVisible = false
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }

    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true)
    }
}
