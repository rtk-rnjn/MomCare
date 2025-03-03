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

    override func viewDidLoad() {
        super.viewDidLoad()
        updateElements()
    }
    
    func updateElements() {
        usernameLabel.text = MomCareUser.shared.user?.fullName
    }

}
