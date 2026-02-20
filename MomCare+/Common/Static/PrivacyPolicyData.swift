//
//  PrivacyPolicyData.swift
//  MomCare+
//
//  Created by Aryan singh on 12/02/26.
//

import Foundation

struct PolicySectionItem: Identifiable {
    let id: UUID = .init()
    let title: String
    let content: String
}

enum PrivacyPolicyText {
    static let headerTitle = "Because Every Mom Deserves Care — Including for Her Data"
    static let headerSubtitle = "Learn how we respect and protect your privacy at Momcare+"

    static let contactTitle = "Contact Us"
    static let contactSubtitle = "If you have any questions, concerns, or requests, feel free to reach out to us:"
    static let contactEmail = "Email: privacy@momcare.app"
    static let contactWebsite = "Website: www.momcare.app"
    static let contactFooter = "We’re here to protect your wellness — both physical and digital."

    static let policySections: [PolicySectionItem] = [
        PolicySectionItem(title: "How Momcare+ Works", content: """
        • Momcare+ helps you navigate pregnancy with peace of mind. Our features include:
        • Trimester-specific guidance delivered weekly
        • Mood, diet, hydration, symptom & exercise tracking
        • Reminders for scans, checkups, supplements, and self-care
        • Mental wellness tools like guided breathing and MoodNest
        • TrimesterFlow™ and ProgressHub™ for personalized insights and trend analysis

        To provide this experience, we collect certain information that you choose to share. Here's what we collect and why.
        """),
        PolicySectionItem(title: "What Information We Collect", content: """
        • Profile & Pregnancy Info: Age, due date, pregnancy start date (for trimester tracking), name (optional)
        • Health Data: Symptoms, allergies, pre-existing conditions (e.g., gestational diabetes), medical notes
        • Daily Logs: Mood, hydration, food intake, energy levels, exercise tracking
        • Reminders & Notes: Appointment entries, calendar events, scan dates (if synced with iOS calendar)

        Device & Diagnostic Data:
        • Device type, iOS version (e.g., iPhone 14, iOS 17.2)
        • App version and usage analytics
        • Crash logs and error reporting (anonymous and aggregated)
        """),
        PolicySectionItem(title: "Why We Collect Your Data", content: """
        • Generate weekly updates based on your pregnancy stage
        • Track diet/exercise progress and show health trends in ProgressHub
        • Send custom reminders for hydration, supplements, or medical checkups
        • Suggest calming music, exercises, and mindfulness tools
        • Enhance motivation through streaks and rewards
        • Improve app performance and reduce bugs

        We do not sell, rent, or monetize your data in any way. Ever.
        """),
        PolicySectionItem(title: "How We Protect Your Data", content: """
        • On-device encryption of sensitive health and mood data
        • Encrypted cloud storage via GDPR-compliant platforms (e.g., AWS, Firebase, MongoDB Atlas) if sync is enabled
        • Token-based authentication and secure APIs
        • Access controls limiting who can see your data, even internally

        You retain full ownership of your data at all times.
        """),
        PolicySectionItem(title: "Your Privacy Rights", content: """
        • Right to Access – See what data we’ve collected about you
        • Right to Correct – Update inaccurate or outdated profile info
        • Right to Delete – Request deletion of your entire account and associated data
        • Right to Withdraw Consent – Disable features like tracking, notifications, or cloud sync at any time
        • Right to Export – GDPR-compliant data export available upon request
        """)
    ]
}
