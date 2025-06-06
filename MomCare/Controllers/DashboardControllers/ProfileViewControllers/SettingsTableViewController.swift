//
//  SettingsTableViewController.swift
//  MomCare
//
//  Created by Khushi Rana on 02/03/25.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet var emailAddressLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateElements()
    }

    func updateElements() {
        if let email = MomCareUser.shared.user?.emailAddress {
            emailAddressLabel.text = email
        } else {
            emailAddressLabel.text = "Not set"
        }
    }
}
