//
//  InitialTabBarController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 16/01/25.
//

import UIKit
import OSLog

private let logger: Logger = .init(subsystem: "com.MomCare.InitialTabBarController", category: "ViewController")

class InitialTabBarController: UITabBarController {

    // MARK: Internal

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            await self.refreshToken()
        }
    }

    func refreshToken() async {
        var retryCount = 0
        while true {
            let refreshed = await MomCareUser.shared.refreshToken()
            if refreshed {
                logger.info("Refresh Token successful")
                break
            }
            if !refreshed && retryCount >= 5 {
                logger.error("Refresh Token failed after 5 retries")
                DispatchQueue.main.async {
                    self.navigateToLogin()
                }
                break
            }
            retryCount += 1
            logger.error("Refreshing Failed. Sleeping for \(retryCount) seconds before retrying. Retry count: \(retryCount)")
            try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * retryCount))
        }
    }

    // MARK: Private

    private func navigateToLogin() {
        let actions = [
            AlertActionHandler(title: "Login", style: .default) { _ in
                Utils.remove("isUserSignedUp")
                self.performSegue(withIdentifier: "segueShowFrontPageNavigationController", sender: nil)
            },
            AlertActionHandler(title: "Try Again", style: .default) { _ in
                Task {
                    await self.refreshToken()
                }
            }
        ]
        let alert = Utils.getAlert(title: "Client-Server out of sync", message: "This is awkward. We failed to authenticate you. Please login again", actions: actions)
        present(alert, animated: true)
    }
}
