import Foundation

struct LicenseInfo: Identifiable {
    let id: UUID = .init()
    let name: String
    let license: String
    let urlString: String
}

enum LicenseData {
    static let appLicense: [LicenseInfo] = [
        .init(
            name: "MomCare+",
            license: "CC BY-NC-ND 4.0 License",
            urlString: "https://creativecommons.org/licenses/by-nc-nd/4.0/deed.en"
        )
    ]

    static let projectReport: [LicenseInfo] = [
        .init(
            name: "MomCare+ Project Report",
            license: "View project documentation",
            urlString: "https://github.com/rtk-rnjn/MomCare"
        )
    ]

    static let thirdPartyLicenses: [LicenseInfo] = [
        .init(
            name: "LNPopupUI",
            license: "MIT License",
            urlString: "https://github.com/LeoNatan/LNPopupUI"
        )
    ]
}
