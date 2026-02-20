//
//  GDPRData.swift
//  MomCare+
//
//  Created by Aryan singh on 12/02/26.
//

import Foundation

struct GDPRRightItem: Identifiable {
    let id: UUID = .init()
    let iconName: String
    let title: String
    let description: String
}

enum GDPRData {
    static let allRights: [GDPRRightItem] = [
        GDPRRightItem(
            iconName: "person.text.rectangle.fill",
            title: "The Right to Access",
            description: "You have the right to request a copy of the personal data we hold about you."
        ),
        GDPRRightItem(
            iconName: "pencil.circle.fill",
            title: "The Right to Rectification",
            description: "If you believe any of the data we hold about you is inaccurate or incomplete, you have the right to have it corrected."
        ),
        GDPRRightItem(
            iconName: "trash.fill",
            title: "The Right to Erasure",
            description: "You can request that we delete your personal data from our systems. This is also known as the 'Right to be Forgotten'."
        ),
        GDPRRightItem(
            iconName: "pause.circle.fill",
            title: "The Right to Restrict Processing",
            description: "You have the right to request that we temporarily or permanently stop processing all or some of your personal data."
        ),
        GDPRRightItem(
            iconName: "arrow.down.doc.fill",
            title: "The Right to Data Portability",
            description: "You can request a copy of your personal data in a common, machine-readable format to transfer to another service."
        ),
        GDPRRightItem(
            iconName: "speaker.slash.fill",
            title: "The Right to Object",
            description: "You have the right to object to us processing your personal data for specific purposes, such as direct marketing."
        ),
    ]
}
