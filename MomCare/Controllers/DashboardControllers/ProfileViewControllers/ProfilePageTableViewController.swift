//
//  ProfilePageTableViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 17/02/25.
//

import UIKit

class ProfilePageTableViewController: UITableViewController {

    var logoutHandler: (() -> Void)?

    @IBAction func logoutTapped() {
        let actions = [
            AlertActionHandler(title: "Cancel", style: .cancel, handler: nil),
            AlertActionHandler(title: "Logout", style: .destructive) { _ in
                Utils.remove("isUserSignedUp")
                self.dismiss(animated: true) {
                    self.logoutHandler?()
                }
            }
        ]
        let message = "Are you sure you want to logout?"
        let alert = Utils.getAlert(title: "Logout?", message: message, actions: actions)
        present(alert, animated: true)
    }
}
