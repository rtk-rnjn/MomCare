//
//  WatchConnector+WatchOS.swift
//  MomCare
//
//  Created by Aryan Singh on 17/09/25.
//

import Foundation
import WatchConnectivity

#if os(watchOS)
extension WatchConnector {
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        if let text = message["message"] as? String, text == "ping" {
            replyHandler(["message": "pong"])
            Watcher.shared.pongReceived = true
        }
    }
}
#endif

class Watcher: ObservableObject {
    @MainActor static let shared: Watcher = .init()

    @Published var pongReceived: Bool = false
}
