//
//  OTPScreenViewController.swift
//  MomCare
//
//  Created by RITIK RANJAN on 08/06/25.
//

import SwiftUI

class OTPScreenViewController: UIHostingController<OTPScreen> {

    // MARK: Lifecycle

    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: OTPScreen())
    }

    // MARK: Internal

    var emailAddress: String!
    var password: String!

    var segueIdentifier: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        rootView.viewController = self

        Task {
            await requestOTP()
        }
    }

    func requestOTP() async -> Bool? {
        return await MomCareUser.shared.requestOTP()
    }

    func resendOTP() async -> Bool? {
        return await MomCareUser.shared.resendOTP()
    }

    func verifyOTP(otp: String) async -> Bool? {
        #if DEBUG
        Utils.save(forKey: "isUserSignedUp", withValue: true)
        return true
        #else
        guard let status = await MomCareUser.shared.verifyOTP(otp: otp) else {
            return false
        }
        _ = await MomCareUser.shared.refreshToken()
        if status {
            Utils.save(forKey: "isUserSignedUp", withValue: true)
        }

        return status
        #endif // DEBUG
    }

    func navigate() async {
        let success = await MomCareUser.shared.automaticFetchUserFromDatabase()

        if success && MomCareUser.shared.user?.dueDateTimestamp == nil {
            DispatchQueue.main.async {
                Utils.remove("isUserSignedUp")
                self.performSegue(withIdentifier: "segueShowSignUpDetailsTableViewController", sender: nil)
            }
            return
        }

        guard let identifier = segueIdentifier else {
            return
        }

        DispatchQueue.main.async {
            self.performSegue(withIdentifier: identifier, sender: nil)
        }
    }
}
