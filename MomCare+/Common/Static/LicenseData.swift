//
//  LicenseData.swift
//  MomCare+
//
//  Created by Aryan singh on 13/02/26.
//

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
            license: "GNU General Public License v2.0",
            urlString: "https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html"
        ),
    ]

    static let projectReport: [LicenseInfo] = [
        .init(
            name: "MomCare+ Project Report",
            license: "View project documentation",
            urlString: "https://github.com/rtk-rnjn/MomCare"
        ),
    ]

    static let thirdPartyLicenses: [LicenseInfo] = [
        .init(
            name: "LNPopupController",
            license: "MIT License",
            urlString: "https://github.com/LeoNatan/LNPopupController"
        ),
        .init(
            name: "FSCalendar",
            license: "MIT License",
            urlString: "https://github.com/WenchaoD/FSCalendar"
        ),
    ]
}
