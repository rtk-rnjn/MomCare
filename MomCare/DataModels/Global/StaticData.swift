//
//  StaticData.swift
//  MomCare
//
//  Created by Ritik Ranjan on 10/01/25.
//

import Foundation

import UIKit
import SwiftUI

struct FrontPageImage {

    // MARK: Lifecycle

    init(imageName: String, heading: String) {
        self.imageName = imageName
        self.heading = heading
    }

    // MARK: Internal

    var imageName: String
    var heading: String

    var image: UIImage? {
        UIImage(named: imageName)
    }

}

enum FrontPageData {
    public static let images: [FrontPageImage] = [
        .init(imageName: "Image", heading: "Personalised plans curated just for you"),
        .init(imageName: "Image 1", heading: "Receive insights for every trimester"),
        .init(imageName: "Image 2", heading: "Track your progress effortlessly"),
        .init(imageName: "Image 3", heading: "Never miss a moment with reminders")
    ]

    public static func getImage(at indexPath: IndexPath) -> UIImage? {
        return images[indexPath.row].image
    }

    public static func getHeading(at indexPath: IndexPath) -> String {
        return images[indexPath.row].heading
    }
}

enum CountryData {
    public static let countryCodes: [String: String] = [
        // https://pastebin.com/raw/AE0Q8cJM

        "93": "Afghanistan",
        "355": "Albania",
        "213": "Algeria",
        "684": "American Samoa",
        "376": "Andorra",
        "244": "Angola",
        "1264": "Anguilla",
        "1268": "Antigua and Barbuda",
        "54": "Argentina Republic",
        "374": "Armenia",
        "297": "Aruba",
        "61": "Australia",
        "43": "Austria",
        "994": "Azerbaijan",
        "1242": "Bahamas",
        "973": "Bahrain",
        "880": "Bangladesh",
        "1246": "Barbados",
        "375": "Belarus",
        "32": "Belgium",
        "501": "Belize",
        "229": "Benin",
        "1441": "Bermuda",
        "975": "Bhutan",
        "591": "Bolivia",
        "387": "Bosnia & Herzegov.",
        "267": "Botswana",
        "55": "Brazil",
        "284": "British Virgin Islands",
        "673": "Brunei Darussalam",
        "359": "Bulgaria",
        "226": "Burkina Faso",
        "257": "Burundi",
        "855": "Cambodia",
        "237": "Cameroon",
        "238": "Cape Verde",
        "1345": "Cayman Islands",
        "236": "Central African Rep.",
        "235": "Chad",
        "56": "Chile",
        "86": "China",
        "57": "Colombia",
        "269": "Comoros",
        "243": "Congo, Dem. Rep.",
        "242": "Congo, Republic",
        "682": "Cook Islands",
        "506": "Costa Rica",
        "385": "Croatia",
        "53": "Cuba",
        "357": "Cyprus",
        "420": "Czech Rep.",
        "45": "Denmark",
        "253": "Djibouti",
        "1767": "Dominica",
        "1809": "Dominican Republic",
        "593": "Ecuador",
        "20": "Egypt",
        "503": "El Salvador",
        "240": "Equatorial Guinea",
        "291": "Eritrea",
        "372": "Estonia",
        "251": "Ethiopia",
        "500": "Falkland Islands (Malvinas)",
        "298": "Faroe Islands",
        "679": "Fiji",
        "358": "Finland",
        "33": "France",
        "594": "French Guiana",
        "689": "French Polynesia",
        "241": "Gabon",
        "220": "Gambia",
        "995": "Georgia",
        "49": "Germany",
        "233": "Ghana",
        "350": "Gibraltar",
        "30": "Greece",
        "299": "Greenland",
        "1473": "Grenada",
        "590": "Guadeloupe ",
        "1671": "Guam",
        "502": "Guatemala",
        "224": "Guinea",
        "245": "Guinea-Bissau",
        "592": "Guyana",
        "509": "Haiti",
        "504": "Honduras",
        "852": "Hongkong, China",
        "36": "Hungary",
        "354": "Iceland",
        "91": "India",
        "62": "Indonesia",
        "882": "International Networks",
        "98": "Iran ",
        "964": "Iraq",
        "353": "Ireland",
        "972": "Israel",
        "39": "Italy",
        "225": "Ivory Coast",
        "1876": "Jamaica",
        "81": "Japan",
        "962": "Jordan",
        "7": "Kazakhstan",
        "254": "Kenya",
        "686": "Kiribati",
        "850": "Korea N., Dem. People's Rep.",
        "82": "Korea S, Republic of",
        "383": "Kosovo",
        "965": "Kuwait",
        "996": "Kyrgyzstan",
        "856": "Laos P.D.R.",
        "371": "Latvia",
        "961": "Lebanon",
        "266": "Lesotho",
        "231": "Liberia",
        "218": "Libya",
        "423": "Liechtenstein",
        "370": "Lithuania",
        "352": "Luxembourg",
        "853": "Macao, China",
        "389": "Macedonia",
        "261": "Madagascar",
        "265": "Malawi",
        "60": "Malaysia",
        "960": "Maldives",
        "223": "Mali",
        "356": "Malta",
        "596": "Martinique (French Department of)",
        "222": "Mauritania",
        "230": "Mauritius",
        "52": "Mexico",
        "691": "Micronesia",
        "373": "Moldova",
        "377": "Monaco",
        "976": "Mongolia",
        "382": "Montenegro",
        "1664": "Montserrat",
        "212": "Morocco",
        "258": "Mozambique",
        "95": "Myanmar (Burma)",
        "264": "Namibia",
        "977": "Nepal",
        "31": "Netherlands",
        "599": "Netherlands Antilles",
        "687": "New Caledonia",
        "64": "New Zealand",
        "505": "Nicaragua",
        "227": "Niger",
        "234": "Nigeria",
        "683": "Niue",
        "47": "Norway",
        "968": "Oman",
        "92": "Pakistan",
        "680": "Palau (Republic of)",
        "970": "Palestinian Territory",
        "507": "Panama",
        "675": "Papua New Guinea",
        "595": "Paraguay",
        "51": "Peru",
        "63": "Philippines",
        "48": "Poland",
        "351": "Portugal",
        "974": "Qatar",
        "262": "Reunion",
        "40": "Romania",
        "79": "Russian Federation",
        "250": "Rwanda",
        "1869": "Saint Kitts and Nevis",
        "1758": "Saint Lucia",
        "685": "Samoa",
        "378": "San Marino",
        "239": "Sao Tome & Principe",
        "870": "Satellite Networks",
        "966": "Saudi Arabia",
        "221": "Senegal",
        "381": "Serbia ",
        "248": "Seychelles",
        "232": "Sierra Leone",
        "65": "Singapore",
        "421": "Slovakia",
        "386": "Slovenia",
        "677": "Solomon Islands",
        "252": "Somalia",
        "27": "South Africa",
        "34": "Spain",
        "94": "Sri Lanka",
        "508": "St. Pierre & Miquelon",
        "1784": "St. Vincent & Gren.",
        "249": "Sudan",
        "597": "Suriname",
        "268": "Swaziland",
        "46": "Sweden",
        "41": "Switzerland",
        "963": "Syrian Arab Republic",
        "886": "Taiwan",
        "992": "Tajikistan",
        "255": "Tanzania",
        "66": "Thailand",
        "670": "Timor-Leste",
        "228": "Togo",
        "676": "Tonga",
        "1868": "Trinidad and Tobago",
        "216": "Tunisia",
        "90": "Turkey",
        "993": "Turkmenistan",
        "256": "Uganda",
        "380": "Ukraine",
        "971": "United Arab Emirates",
        "44": "United Kingdom",
        "1": "United States",
        "598": "Uruguay",
        "998": "Uzbekistan",
        "678": "Vanuatu",
        "58": "Venezuela",
        "84": "Viet Nam",
        "1340": "Virgin Islands, U.S.",
        "967": "Yemen",
        "260": "Zambia",
        "263": "Zimbabwe"
    ]
}

enum AppColors {
    static let accentColor: Color = .init(hex: "924350")
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

struct PolicySectionItem: Identifiable {
    let id: UUID = .init()
    let title: String
    let content: String
}
