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
    @IBOutlet var oldPasswordField: UITableViewCell!
    @IBOutlet var newPasswordField: UITableViewCell!
    @IBOutlet var confirmPasswordField: UITableViewCell!
    @IBOutlet var changePasswordButton: UIButton!
    
    var isPasswordFieldsVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePageElements()
        changePasswordButtonArrow()
    }
    
    func updatePageElements(){
        guard let user = MomCareUser.shared.user else { return }
        
        emailLabel.text = user.emailAddress
        phoneNumberLabel.text = user.phoneNumber
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0{
            isPasswordFieldsVisible.toggle()
            changePasswordButtonArrow()
            
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && [1, 2, 3].contains(indexPath.row) {
            return isPasswordFieldsVisible ? UITableView.automaticDimension : 0
        }

        return UITableView.automaticDimension
    }
    
    func changePasswordButtonArrow() {
        let imageName = isPasswordFieldsVisible ? "chevron.up" : "chevron.down"
        let image = UIImage(systemName: imageName)
        
        changePasswordButton.contentHorizontalAlignment = .left
        changePasswordButton.semanticContentAttribute = .forceRightToLeft
        
        changePasswordButton.setImage(image, for: .normal)
        changePasswordButton.configuration?.imagePadding = 160
    }
}
