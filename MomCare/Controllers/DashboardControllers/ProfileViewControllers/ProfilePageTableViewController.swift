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

    @IBAction func logoutTapped() {
        let actions = [
            AlertActionHandler(title: "Cancel", style: .cancel, handler: nil),
            AlertActionHandler(title: "Logout", style: .destructive) { _ in
                Utils.remove("isUserSignedUp")
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let sceneDelegate = windowScene.delegate as? SceneDelegate {
                 let storyboard = UIStoryboard(name: "Main", bundle: nil)
                 let frontVC = storyboard.instantiateViewController(withIdentifier: "FrontViewController")

                 let navController = UINavigationController(rootViewController: frontVC)
                 sceneDelegate.window?.rootViewController = navController
                 sceneDelegate.window?.makeKeyAndVisible()
             }
        }
        ]
        let message = "Are you sure you want to logout?"
        let alert = Utils.getAlert(title: "Logout?", message: message, actions: actions)
        present(alert, animated: true)
    }
}
