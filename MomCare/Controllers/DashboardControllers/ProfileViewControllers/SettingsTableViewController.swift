//
//  SettingsTableViewController.swift
//  MomCare
//
//  Created by Aryan Singh on 13/06/25.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet var userEmail: UILabel!
    @IBOutlet var userPhoneNumber: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePageElements()

    }
    
    func updatePageElements(){
        guard let user = MomCareUser.shared.user else { return }
        
        userEmail.text = user.emailAddress
        userPhoneNumber.text = user.phoneNumber
    }
}
