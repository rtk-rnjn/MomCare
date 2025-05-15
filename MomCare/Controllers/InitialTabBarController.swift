//
//  InitialTabBarController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 16/01/25.
//

import UIKit

class InitialTabBarController: UITabBarController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            let refreshed = await MomCareUser.shared.refreshToken()
            if !refreshed {
                DispatchQueue.main.async {
                    self.navigateToLogin()
                }
            }
        }
    }
    
    private func navigateToLogin() {
        let actions = [
            AlertActionHandler(title: "OK", style: .default) { alertAction in
                self.performSegue(withIdentifier: "segueShowFrontPageNavigationController", sender: nil)
            }
        ]
        let alert = Utils.getAlert(title: "Login Expired", message: "Please login again.", actions: actions)
        present(alert, animated: true) {
            Utils.remove("isUserSignedUp")
        }
    }
}
