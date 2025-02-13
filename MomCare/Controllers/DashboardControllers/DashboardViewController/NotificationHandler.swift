//
//  NotificationHandler.swift
//  MomCare
//
//  Created by Ritik Ranjan on 13/02/25.
//

import Foundation
import UserNotifications
import UIKit

extension DashboardViewController {
    func requestAccessForNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                center.getNotificationSettings { settings in
                    guard settings.authorizationStatus == .authorized else { return }
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
    }

    public static func createNotification(title: String? = nil, body: String? = nil, date: Date? = nil, userInfo: [String: Any]? = nil) {
        Utils.createNotification(title: title, body: body, date: date, userInfo: userInfo)
    }
}
