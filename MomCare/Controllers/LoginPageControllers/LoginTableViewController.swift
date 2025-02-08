import UIKit

class LoginTableViewController: UITableViewController {

    // MARK: Internal

    @IBOutlet var emailAddressField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var signInButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        updateView()
    }

    @IBAction func textFieldChanged(_ sender: UITextField) {
        updateView()
    }

    @IBAction func signInButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "segueShowInitialTabBarController", sender: nil)
    }

    // MARK: Private

    private func updateView() {
        signInButton.isEnabled = emailAddressField.text?.isEmpty == false && passwordField.text?.isEmpty == false && emailAddressField.text?.isValidEmail() == true
    }

}
