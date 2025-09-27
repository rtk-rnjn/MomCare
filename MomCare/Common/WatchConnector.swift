//
//  WatchConnector.swift
//  MomCare
//
//  Created by Aryan Singh on 17/09/25.
//

@preconcurrency import WatchConnectivity
import Foundation
import OSLog

#if os(iOS)
private let logger: os.Logger = .init(subsystem: "com.MomCare.WatchConnector", category: "WatchConnector")
#elseif os(watchOS)
private let logger: os.Logger = .init(subsystem: "com.MomCare.WatchApp.WatchConnector", category: "WatchConnector")
#endif

@MainActor
class WatchConnector: NSObject, ObservableObject {

    // MARK: Lifecycle

    override init() {
        super.init()
        session.delegate = self
        session.activate()
    }

    // MARK: Internal

    // MARK: Singleton
    static let shared: WatchConnector = .init()

    var session: WCSession = .default

    @Published var isReachable: Bool = WCSession.default.isReachable
    @Published var activationState: WCSessionActivationState = WCSession.default.activationState

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
extension WatchConnector: @preconcurrency WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        DispatchQueue.main.async {
            self.activationState = activationState
        }

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
    #endif

    func sessionReachabilityDidChange(_ session: WCSession) {
        logger.debug("Session reachability changed: \(session.isReachable)")
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
}
