//
//  MultipeerHandler.swift
//  MomCare
//
//  Created by Aryan Singh on 18/09/25.
//

import Foundation
import MultipeerConnectivity
import OSLog

private let logger: Logger = .init(subsystem: "com.MomCare.MultipeerHandler", category: "MultipeerHandler")

@MainActor
class MultipeerHandler: NSObject {

    // MARK: Lifecycle

    private override init() {
        peerID = MCPeerID(displayName: "MomCare+ \(UUID().uuidString.prefix(4))")
        super.init()
        setupSession()
    }

    // MARK: Internal

    @MainActor static let shared: MultipeerHandler = .init()

    var onPeerConnected: ((MCPeerID) -> Void)?
    var onPeerDisconnected: ((MCPeerID) -> Void)?

    /// Callbacks to be invoked when data is received. Each callback takes the received Data and the MCPeerID of the sender as parameters.
    var callbacks: [(Data, MCPeerID) -> Void] = []

    var session: MCSession?
    var advertiser: MCNearbyServiceAdvertiser?
    var browser: MCNearbyServiceBrowser?

    var peerID: MCPeerID

    var connectedPeers: [MCPeerID] {
        session?.connectedPeers ?? []
    }

    func startHosting() {
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()

        let displayName = peerID.displayName

        logger.info("Started hosting with peer ID: \(displayName)")
    }

    func stopHosting() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
    }

    func startBrowsing() {
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()

        let displayName = peerID.displayName

        logger.info("Started browsing for peers with peer ID: \(displayName)")
    }

    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
    }

    func send(data: Data, to peers: [MCPeerID]? = nil) {
        guard let session else { return }
        let targetPeers = peers ?? session.connectedPeers
        guard !targetPeers.isEmpty else {
            logger.warning("No connected peers to send data to.")
            return
        }

        logger.debug("Sending data to peers: \(targetPeers.map { $0.displayName })")

        do {
            try session.send(data, toPeers: targetPeers, with: .reliable)
        } catch {
            logger.error("Error sending data: \(String(describing: error))")
        }
    }

    func disconnect() {
        session?.disconnect()
        stopHosting()
        stopBrowsing()
    }

    // MARK: Private

    private let serviceType = "MomCare-share"

    private func setupSession() {
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self

    }

}

extension MultipeerHandler: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                logger.info("Connected to peer: \(peerID.displayName)")
                self.onPeerConnected?(peerID)

            case .notConnected:
                logger.info("Disconnected from peer: \(peerID.displayName)")
                self.onPeerDisconnected?(peerID)

            case .connecting:
                logger.info("Connecting to peer: \(peerID.displayName)")
            @unknown default: break
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        for callback in callbacks {
            callback(data, peerID)
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        logger.info("Started receiving resource '\(resourceName)' from peer: \(peerID.displayName) with progress: \(progress.fractionCompleted)")
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {
        if let error {
            logger.error("Error receiving resource '\(resourceName)' from peer: \(peerID.displayName): \(String(describing: error))")
        } else {
            logger.info("Finished receiving resource '\(resourceName)' from peer: \(peerID.displayName) at URL: \(String(describing: localURL))")
        }
    }
}
