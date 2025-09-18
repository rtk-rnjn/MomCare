//
//  WatchConnector+WatchOS.swift
//  MomCare
//
//  Created by Aryan Singh on 17/09/25.
//

import Foundation
import WatchConnectivity

extension WatchConnector {
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        if let text = message["message"] as? String, text == "ping" {
            replyHandler(["message": "pong"])
            DispatchQueue.main.async {
                WatchObserver.shared.pongReceived = true
            }
            Utils.createNotification(title: "MomCare+", body: "Received ping from MomCare+")
        }
    }
}

class WatchObserver: ObservableObject {
    @MainActor static let shared: WatchObserver = .init()

    @Published var pongReceived: Bool = false
}
