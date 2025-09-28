//
//  DashboardViewController+NotificationHandler.swift
//  MomCare
//
//  Created by Ritik Ranjan on 13/02/25.
//

import Foundation
import UserNotifications
import UIKit
import OSLog

private let logger: Logger = .init(subsystem: "com.MomCare.DashboardViewController", category: "ViewController")

extension DashboardViewController {
    func requestAccessForNotification() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                let settings = await center.notificationSettings()
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } catch {
            logger.error("Error while requesting notification access: \(String(describing: error))")
        }
    }

    public static func createNotification(title: String? = nil, body: String? = nil, date: Date? = nil, userInfo: [String: Any]? = nil) {
        Utils.createNotification(title: title, body: body, date: date, userInfo: userInfo)
    }
}
