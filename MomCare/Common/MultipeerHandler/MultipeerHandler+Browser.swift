//
//  MultipeerHandler+Browser.swift
//  MomCare
//
//  Created by Aryan Singh on 18/09/25.
//

import MultipeerConnectivity

extension MultipeerHandler: @preconcurrency MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String: String]?) {
        if let session {
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
}
