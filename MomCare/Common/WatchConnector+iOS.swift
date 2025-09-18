//
//  WatchConnector+iOS.swift
//  MomCare
//
//  Created by Aryan Singh on 17/09/25.
//

import WatchConnectivity

extension WatchConnector {
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        if let text = message["message"] as? String, text == "ping" {
            replyHandler(["message": "pong"])
            Utils.createNotification(title: "MomCare+ Watch", body: "Received ping from watch")
        }
    }
}
