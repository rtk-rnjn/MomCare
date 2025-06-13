//
//  ProfilePageTableViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 17/02/25.
//

import UIKit

class ProfilePageTableViewController: UITableViewController {
    @IBOutlet var profileImageView: UIImageView?
    @IBOutlet var usernameLabel: UILabel!

    @IBOutlet var logoutLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateElements()

        // tap gesture for  logout Label
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(logoutTapped))
        logoutLabel.isUserInteractionEnabled = true
        logoutLabel.addGestureRecognizer(tapGesture)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func updateElements() {
        usernameLabel.text = MomCareUser.shared.user?.fullName
    }

    @objc func logoutTapped() {
        let actions = [
            AlertActionHandler(title: "Cancel", style: .cancel, handler: nil),
            AlertActionHandler(title: "Logout", style: .destructive) { _ in
                Utils.remove("isUserSignedUp")
                self.dismiss(animated: true) {
                    self.performSegue(withIdentifier: "segueShowFrontPageNavigationController", sender: nil)
                }
            }
        ]
        let message = "Are you sure you want to logout?"
        let alert = Utils.getAlert(title: "Logout?", message: message, actions: actions)
        present(alert, animated: true)
    }
}
