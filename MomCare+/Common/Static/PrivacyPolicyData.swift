import Foundation

struct PolicySectionItem: Identifiable {
    let id: UUID = .init()
    let title: String
    let content: String
}

enum PrivacyPolicyText {
    static var headerTitle: String { String(localized: "privacy_header_title") }
    static var headerSubtitle: String { String(localized: "privacy_header_subtitle") }

    static var contactTitle: String { String(localized: "privacy_contact_title") }
    static var contactSubtitle: String { String(localized: "privacy_contact_subtitle") }
    static var contactEmail: String { String(localized: "privacy_contact_email") }
    static var contactWebsite: String { String(localized: "privacy_contact_website") }
    static var contactFooter: String { String(localized: "privacy_contact_footer") }

    static var policySections: [PolicySectionItem] {
        [
            PolicySectionItem(
                title: String(localized: "privacy_section_works_title"),
                content: String(localized: "privacy_section_works_content")
            ),
            PolicySectionItem(
                title: String(localized: "privacy_section_collect_title"),
                content: String(localized: "privacy_section_collect_content")
            ),
            PolicySectionItem(
                title: String(localized: "privacy_section_why_title"),
                content: String(localized: "privacy_section_why_content")
            ),
            PolicySectionItem(
                title: String(localized: "privacy_section_protect_title"),
                content: String(localized: "privacy_section_protect_content")
            ),
            PolicySectionItem(
                title: String(localized: "privacy_section_rights_title"),
                content: String(localized: "privacy_section_rights_content")
            )
        ]
    }
}
