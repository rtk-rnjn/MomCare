//
//  WatchConnector.swift
//  MomCare
//
//  Created by Aryan Singh on 17/09/25.
//

import WatchConnectivity
import Foundation
import OSLog

private let logger: os.Logger = .init(subsystem: "com.MomCare.WatchConnector", category: "WatchConnector")

@MainActor
class WatchConnector: NSObject, ObservableObject {

    // MARK: Lifecycle

    override init() {
        super.init()
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: Internal

    static let shared: WatchConnector = .init()

    var session: WCSession = .default

    func send(message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil) {
        if session.isReachable {
            session.sendMessage(message, replyHandler: replyHandler, errorHandler: { error in
                logger.error("Something fucked: \(String(describing: error))")
            })
        } else {
            logger.warning("Watch is not reachable")
        }
    }

    func transfer(userInfo: [String: Any]) {
        session.transferUserInfo(userInfo)
    }
}

extension WatchConnector: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if let error {
            logger.warning("WCSession activation failed: \(String(describing: error))")
        } else {
            // .rawValue == 2 == .activated
            logger.info("WCSession activated with state: \(activationState.rawValue)")
        }
    }

    #if os(iOS)
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {}
    #endif

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {}

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {}
}
