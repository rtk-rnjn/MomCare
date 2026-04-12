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
    static var allSections: [LegalSectionItem] {
        [
            LegalSectionItem(type: .standard(
                icon: "checkmark.seal.fill",
                title: String(localized: "terms_acceptance_title"),
                content: String(localized: "terms_acceptance_content")
            )),
            LegalSectionItem(type: .eligibility),
            LegalSectionItem(type: .overview),
            LegalSectionItem(type: .standard(
                icon: "exclamationmark.triangle.fill",
                title: String(localized: "terms_disclaimer_title"),
                content: String(localized: "terms_disclaimer_content")
            )),
            LegalSectionItem(type: .standard(
                icon: "person.fill.checkmark",
                title: String(localized: "terms_responsibilities_title"),
                content: String(localized: "terms_responsibilities_content")
            )),
            LegalSectionItem(type: .standard(
                icon: "c.circle.fill",
                title: String(localized: "terms_license_title"),
                content: String(localized: "terms_license_content")
            )),
            LegalSectionItem(type: .standard(
                icon: "lock.shield.fill",
                title: String(localized: "terms_data_consent_title"),
                content: String(localized: "terms_data_consent_content")
            )),
            LegalSectionItem(type: .thirdParty),
            LegalSectionItem(type: .standard(
                icon: "creditcard.fill",
                title: String(localized: "terms_subscriptions_title"),
                content: String(localized: "terms_subscriptions_content")
            )),
            LegalSectionItem(type: .standard(
                icon: "hand.raised.fill",
                title: String(localized: "terms_liability_title"),
                content: String(localized: "terms_liability_content")
            )),
            LegalSectionItem(type: .standard(
                icon: "building.columns.fill",
                title: String(localized: "terms_law_title"),
                content: String(localized: "terms_law_content")
            )),
            LegalSectionItem(type: .standard(
                icon: "envelope.fill",
                title: String(localized: "terms_contact_us_title"),
                content: String(localized: "terms_contact_us_content")
            ))
        ]
    }
}
