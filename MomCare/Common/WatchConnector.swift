//
//  WatchConnector.swift
//  MomCare
//
//  Created by Aryan Singh on 17/09/25.
//

import WatchConnectivity
import Foundation
import OSLog
import Combine

#if os(iOS)
private let logger: os.Logger = .init(subsystem: "com.MomCare.WatchConnector", category: "WatchConnector")
#elseif os(watchOS)
private let logger: os.Logger = .init(subsystem: "com.MomCare.WatchApp.WatchConnector", category: "WatchConnector")
#endif

/// A singleton class responsible for managing communication between the iOS app and the paired Apple Watch using `WatchConnectivity`.
class WatchConnector: NSObject, WCSessionDelegate {

    // MARK: Lifecycle

    /// Initializes the WatchConnector and activates the WCSession.
    override init() {
        super.init()
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: Internal

    /// Shared singleton instance for global access.
    nonisolated(unsafe) static let shared: WatchConnector = .init()

    /// The default `WCSession` instance used for communication.
    var session: WCSession {
        return WCSession.default
    }

    /// Sends a message dictionary to the paired device if reachable.
    ///
    /// - Parameters:
    ///   - message: The dictionary containing data to send.
    ///   - replyHandler: Optional closure to handle a reply from the paired device.
    func send(message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil) {
        if session.isReachable {
            session.sendMessage(message, replyHandler: replyHandler, errorHandler: { error in
                logger.error("Send error: \(String(describing: error))")
            })
        } else {
            logger.warning("Paired Device is not reachable")
        }
    }

    /// Transfers a user info dictionary to the paired device asynchronously.
    ///
    /// - Parameter userInfo: The dictionary to transfer.
    func transfer(userInfo: [String: Any]) {
        session.transferUserInfo(userInfo)
    }

    /// Sends a simple ping message to the paired device.
    func ping() {
        send(message: ["message": "ping"]) { reply in
            logger.info("Received `\(String(describing: reply))` from paired device")
        }
    }

    /// Called when the session activation completes.
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: (any Error)?) {
        if let error {
            logger.warning("WCSession activation failed: \(String(describing: error))")
        } else {
            logger.info("WCSession activated with state: \(activationState.rawValue)")
        }
    }

#if os(iOS)
    /// Called when the session becomes inactive (iOS only).
    func sessionDidBecomeInactive(_ session: WCSession) {
        logger.warning("WCSession became inactive")
    }

    /// Called when the session is deactivated and needs to be reactivated (iOS only).
    func sessionDidDeactivate(_ session: WCSession) {
        logger.warning("WCSession did deactivate")
    }
#endif // os(iOS)

    /// Called when the reachability of the paired device changes.
    func sessionReachabilityDidChange(_ session: WCSession) {
        logger.debug("Session reachability changed: \(session.isReachable)")
    }
}
