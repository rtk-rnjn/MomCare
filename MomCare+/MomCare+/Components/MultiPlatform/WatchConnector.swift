import Combine
import Foundation
import OSLog
import WatchConnectivity

#if os(iOS)
    private let logger: os.Logger = .init(subsystem: "com.MomCare.WatchConnector", category: "WatchConnector")
#elseif os(watchOS)
    private let logger: os.Logger = .init(subsystem: "com.MomCare.WatchApp.WatchConnector", category: "WatchConnector")
#endif

class WatchConnector: NSObject, WCSessionDelegate {

    // MARK: Lifecycle

    override init() {
        super.init()
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: Internal

    static let shared: WatchConnector = .init()

    var session: WCSession {
        WCSession.default
    }

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
            logger.info("Received `\(String(describing: reply))` from paired device")
        }
    }

    func session(_: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if let error {
            logger.warning("WCSession activation failed: \(String(describing: error))")
        } else {
            logger.info("WCSession activated with state: \(activationState.rawValue)")
        }
    }

    #if os(iOS)

        func sessionDidBecomeInactive(_: WCSession) {
            logger.warning("WCSession became inactive")
        }

        func sessionDidDeactivate(_: WCSession) {
            logger.warning("WCSession did deactivate")
        }
    #endif // os(iOS)

    func sessionReachabilityDidChange(_ session: WCSession) {
        logger.debug("Session reachability changed: \(session.isReachable)")
    }
}
