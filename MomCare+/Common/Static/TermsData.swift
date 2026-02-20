//
//  TermsData.swift
//  MomCare+
//
//  Created by Aryan singh on 12/02/26.
//

import Foundation

enum LegalSectionType {
    case standard(icon: String, title: String, content: String)
    case eligibility
    case overview
    case thirdParty
}

struct LegalSectionItem: Identifiable {
    let id: UUID = .init()
    let type: LegalSectionType
}

enum TermsData {
    static let allSections: [LegalSectionItem] = [
        LegalSectionItem(type: .standard(
            icon: "checkmark.seal.fill",
            title: "Acceptance of Terms",
            content: "By downloading, installing, accessing, or using the MomCare mobile application and related services, you acknowledge that you have read, understood, and agreed to be bound by these Terms of Service and our Privacy Policy.\n\nIf you do not agree with these Terms, or any future updates to them, you must not access or use the App. Your continued use of the App after any changes or updates to these Terms constitutes your acceptance of those changes."
        )),
        LegalSectionItem(type: .eligibility),
        LegalSectionItem(type: .overview),
        LegalSectionItem(type: .standard(
            icon: "exclamationmark.triangle.fill",
            title: "Disclaimers and Emergency Guidance",
            content: "All content and features are for informational purposes only and are not a substitute for professional medical advice. In case of any medical emergency, immediately call your doctor or go to the nearest hospital. Use of the MomCare app is at your own discretion and risk."
        )),
        LegalSectionItem(type: .standard(
            icon: "person.fill.checkmark",
            title: "User Responsibilities",
            content: "You agree not to use the app in any unlawful manner, tamper with its functionalities, or submit misleading health data."
        )),
        LegalSectionItem(type: .standard(
            icon: "c.circle.fill",
            title: "License and Intellectual Property",
            content: "MomCare and all associated content, features, and branding are the exclusive intellectual property of MomCare and are protected by law. You are granted a limited, non-exclusive license for personal, non-commercial use only. You may not copy, modify, distribute, or reverse engineer any part of the app."
        )),
        LegalSectionItem(type: .standard(
            icon: "lock.shield.fill",
            title: "Data Consent & Privacy",
            content: "By using our Services, you grant MomCare the right to collect, store, and process your data in accordance with our Privacy Policy. We use anonymized and aggregated data to improve our services and will never sell your personal data."
        )),
        LegalSectionItem(type: .thirdParty),
        LegalSectionItem(type: .standard(
            icon: "creditcard.fill",
            title: "Subscriptions",
            content: "Some advanced features may require a subscription. Payments are processed via the App Store, and you can manage or cancel your subscription in your account settings."
        )),
        LegalSectionItem(type: .standard(
            icon: "hand.raised.fill",
            title: "Limitation of Liability",
            content: "MomCare provides the app “as-is” without warranties. We are not liable for indirect damages from your use of the app and do not guarantee it will be error-free."
        )),
        LegalSectionItem(type: .standard(
            icon: "building.columns.fill",
            title: "Governing Law",
            content: "These terms are governed by the laws of India. Any disputes shall be resolved in the courts of Gautam Budh Nagar."
        )),
        LegalSectionItem(type: .standard(
            icon: "envelope.fill",
            title: "Contact Us",
            content: "For questions or feedback, please contact us at:\n**Email:** support@ourdomain\n**Website:** "
        )),
    ]
}
