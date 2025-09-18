//
//  MultipeerHandler.swift
//  MomCare
//
//  Created by Aryan Singh on 18/09/25.
//

import Foundation
@preconcurrency import MultipeerConnectivity
import OSLog

private let logger: Logger = .init(subsystem: "com.MomCare.MultipeerHandler", category: "MultipeerHandler")

@MainActor
class MultipeerHandler: NSObject {

    // MARK: Lifecycle

    private override init() {
        peerID = MCPeerID(displayName: UIDevice.current.name)
        super.init()
        setupSession()
    }

    // MARK: Internal

    static let shared: MultipeerHandler = .init()

    var onPeerConnected: ((MCPeerID) -> Void)?
    var onPeerDisconnected: ((MCPeerID) -> Void)?
    var onDataReceived: ((Data, MCPeerID) -> Void)?

    var session: MCSession?
    var advertiser: MCNearbyServiceAdvertiser?
    var browser: MCNearbyServiceBrowser?

    func startHosting() {
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    func stopHosting() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
    }

    func startBrowsing() {
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }

    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
    }

    func send(data: Data, to peers: [MCPeerID]? = nil) {
        guard let session else { return }
        let targetPeers = peers ?? session.connectedPeers
        guard !targetPeers.isEmpty else { return }

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

    private let serviceType = "mpc-share" // must be <= 15 chars
    private var peerID: MCPeerID

    private func setupSession() {
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self

    }

}

extension MultipeerHandler: @preconcurrency MCSessionDelegate {
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
        onDataReceived?(data, peerID)
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {}
}
