
import UIKit

class LoginTableViewController: UITableViewController {

    @IBOutlet var emailAddressField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateView()
    }
    
    private func updateView() {
        signInButton.isEnabled = emailAddressField.text?.isEmpty == false && passwordField.text?.isEmpty == false && emailAddressField.text?.isValidEmail() == true
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        updateView()
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        // Try Login
    }
    
}
