//
//  WatchApp.swift
//  MomCare+ Watch Watch App
//
//  Created by Aryan Singh on 17/09/25.
//

import SwiftUI
import UserNotifications
import OSLog

private let logger: Logger = .init(subsystem: "com.MomCare.Watch.WatchApp", category: "WatchApp")

@main
struct WatchApp: App {

    // MARK: Lifecycle

    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                logger.error("Error requesting notification permissions: \(String(describing: error))")
            } else {
                logger.info("Notifications permission granted: \(granted)")
            }
        }
    }

    // MARK: Internal

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
