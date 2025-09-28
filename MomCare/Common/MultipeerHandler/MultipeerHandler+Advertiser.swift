//
//  MultipeerHandler+Advertiser.swift
//  MomCare
//
//  Created by Aryan Singh on 18/09/25.
//

import MultipeerConnectivity

extension MultipeerHandler: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if let session {
            invitationHandler(true, session)
        } else {
            invitationHandler(false, nil)
        }
    }
}
