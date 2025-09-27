//
//  WatchConnector.swift
//  MomCare
//
//  Created by Aryan Singh on 17/09/25.
//

import WatchConnectivity
import Foundation
import OSLog

#if os(iOS)
private let logger: os.Logger = .init(subsystem: "com.MomCare.WatchConnector", category: "WatchConnector")
#elseif os(watchOS)
private let logger: os.Logger = .init(subsystem: "com.MomCare.WatchApp.WatchConnector", category: "WatchConnector")
#endif // os(iOS)

@MainActor
final class WatchConnector: NSObject, ObservableObject {

    // MARK: Lifecycle

    override init() {
        super.init()
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: Internal

    // MARK: Singleton
    static let shared: WatchConnector = .init()

    var session: WCSession {
        return WCSession.default
    }

    // MARK: Messaging

    func send(message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil) {
        if session.isReachable {
            session.sendMessage(message, replyHandler: replyHandler, errorHandler: { error in
                logger.error("Send error: \(String(describing: error))")
            })
        } else {
            logger.warning("Paired Device is not reachable")
        }
    }

    func transfer(userInfo: [String: Any]) {
        session.transferUserInfo(userInfo)
    }

    func ping() {
        send(message: ["message": "ping"]) { reply in
            logger.info("Recieved `\(String(describing: reply))` from Paired Device")
        }
    }
}

// MARK: - WCSessionDelegate
extension WatchConnector: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {

        if let error {
            logger.warning("WCSession activation failed: \(String(describing: error))")
        } else {
            logger.info("WCSession activated with state: \(activationState.rawValue)")
        }
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        logger.warning("WCSession became inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        logger.warning("WCSession did deactivate")
    }
    #endif // os(iOS)

    func sessionReachabilityDidChange(_ session: WCSession) {
        logger.debug("Session reachability changed: \(session.isReachable)")
    }
}
