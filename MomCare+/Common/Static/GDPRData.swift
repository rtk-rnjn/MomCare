import Foundation

struct GDPRRightItem: Identifiable {
    let id: UUID = .init()
    let iconName: String
    let title: String
    let description: String
}

enum GDPRData {
    static var allRights: [GDPRRightItem] {
        [
            GDPRRightItem(
                iconName: "person.text.rectangle.fill",
                title: String(localized: "gdpr_right_access_title"),
                description: String(localized: "gdpr_right_access_description")
            ),
            GDPRRightItem(
                iconName: "pencil.circle.fill",
                title: String(localized: "gdpr_right_rectification_title"),
                description: String(localized: "gdpr_right_rectification_description")
            ),
            GDPRRightItem(
                iconName: "trash.fill",
                title: String(localized: "gdpr_right_erasure_title"),
                description: String(localized: "gdpr_right_erasure_description")
            ),
            GDPRRightItem(
                iconName: "pause.circle.fill",
                title: String(localized: "gdpr_right_restrict_title"),
                description: String(localized: "gdpr_right_restrict_description")
            ),
            GDPRRightItem(
                iconName: "arrow.down.doc.fill",
                title: String(localized: "gdpr_right_portability_title"),
                description: String(localized: "gdpr_right_portability_description")
            ),
            GDPRRightItem(
                iconName: "speaker.slash.fill",
                title: String(localized: "gdpr_right_object_title"),
                description: String(localized: "gdpr_right_object_description")
            )
        ]
    }
}
