//
//  CreditsData.swift
//  MomCare+
//
//  Created by Aryan singh on 12/02/26.
//

import Foundation

struct TeamMember: Identifiable {
    let id: UUID = .init()
    let imageName: String?
    let name: String
    let role: String
}

struct Credit: Identifiable {
    let id: UUID = .init()
    let name: String
    let description: String
}

enum CreditsData {
    static let teamMembers: [TeamMember] = [
        .init(imageName: nil, name: "Aryan Singh", role: "Team Lead, UI/UX & Ideation"),
        .init(imageName: nil, name: "Khushi Rana", role: "Frontend & Research"),
        .init(imageName: nil, name: "Nupur Sharma", role: "Frontend & Research"),
        .init(imageName: nil, name: "Ritik Ranjan", role: "Frontend/Backend Developer")
    ]

    static let mentors: [Credit] = [
        .init(name: "Vinod Kumar", description: "For his dedicated guidance."),
        .init(name: "Valuable Feedback From", description: "Kiran Singh, Probeer Shaw, Runumi Devi and Shruti Sachdeva.")
    ]

    static let specialThanks: [Credit] = [
        .init(name: "Amit Gulati · Apple", description: "For expert insights."),
        .init(name: "Prasad BS · Infosys", description: "For feedback on UI and business aspects.")
    ]
}
