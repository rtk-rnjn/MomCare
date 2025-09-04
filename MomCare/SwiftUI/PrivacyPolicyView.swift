//

//  PrivacyPolicyView.swift

//  MomCare

//

//  Created by Nupur on 25/08/25.

//

import SwiftUI

struct PrivacyPolicyView: View {

    // MARK: Internal

    var body: some View {

        GeometryReader { _ in

            ScrollView {

                VStack(spacing: 24) {

                    VStack(spacing: 16) {

                        ZStack {

                            RoundedRectangle(cornerRadius: 12, style: .continuous)

                                .fill(Color(hex: "FFFFFF").opacity(0.12))

                                .frame(width: 60, height: 60)

                            Image(systemName: "lock.shield")

                                .font(.system(size: 60, weight: .bold))

                                .foregroundColor(accentColor)

                        }

                        Text("Because Every Mom Deserves Care — Including for Her Data")

                            .font(.system(size: 28, weight: .semibold, design: .default))

                            .tracking(-0.5)

                            .multilineTextAlignment(.center)

                            .lineSpacing(0)

                        Text("Learn how we respect and protect your privacy at Momcare+")

                            .font(.subheadline)

                            .foregroundColor(.primary)

                            .multilineTextAlignment(.center)

                    }

                    .padding(.top, 32)

                    .padding(.bottom, 8)

                    Divider()

                    ForEach(policySections) { section in

                        PolicySectionView(title: section.title, content: section.content, accentColor: accentColor)

                        if section.id != policySections.last?.id {

                            Divider()

                                .background(Color.gray.opacity(0.5))

                                .padding(.vertical, 8)

                        }

                    }

                    // Add a divider before the "Contact Us" section

                    Divider()

                        .background(Color.gray.opacity(0.5)) // Ensure the divider is visible

                        .padding(.vertical, 8)

                    VStack(alignment: .leading, spacing: 12) {

                        HStack(spacing: 12) {

                            Image(systemName: "envelope")

                                .font(.title2)

                                .foregroundColor(accentColor)

                                .frame(width: 24, alignment: .center)

                            Text("Contact Us")

                                .font(.title3.weight(.semibold))

                        }

                        Text("If you have any questions, concerns, or requests, feel free to reach out to us:")

                            .font(.subheadline)

                            .foregroundColor(.primary)

                            .lineSpacing(4)

                        VStack(alignment: .leading, spacing: 8) {

                            HStack(spacing: 8) {

                                Image(systemName: "envelope.fill") // SF Symbol for Email

                                    .foregroundColor(accentColor)

                                Text("Email: privacy@momcare.app")

                                    .font(.subheadline)

                                    .foregroundColor(.primary)

                            }

                            HStack(spacing: 8) {

                                Image(systemName: "globe") // SF Symbol for Website

                                    .foregroundColor(accentColor)

                                Text("Website: www.momcare.app")

                                    .font(.subheadline)

                                    .foregroundColor(.primary)

                            }

                        }

                        Text("We’re here to protect your wellness — both physical and digital.")

                            .multilineTextAlignment(.center)

                            .font(.subheadline)

                            .foregroundColor(Color(hex: "924350"))

                            .padding(.top, 8)

                            .frame(maxWidth: .infinity, alignment: .center)

                    }

                    .padding(.top, 16)

                }

                .padding(.horizontal, 24)

                .padding(.bottom, 40)

            }

        }

    }

    // MARK: Private

    private let accentColor: Color = Color(hex: "924350")

    private let policySections: [PolicySectionItem] = PrivacyPolicyData.allSections

}

struct PolicySectionView: View {

    let title: String

    let content: String

    let accentColor: Color

    var body: some View {

        VStack(alignment: .leading, spacing: 12) {

            HStack(spacing: 12) {

                Image(systemName: iconName(for: title)) // Dynamically choose the icon

                    .font(.title2)

                    .foregroundColor(accentColor)

                    .frame(width: 24, alignment: .center)

                Text(title)

                    .font(.title3.weight(.semibold))

            }

            VStack(alignment: .leading, spacing: 8) {

                ForEach(content.split(separator: "\n").filter { line in

                    let trimmed = line.trimmingCharacters(in: .whitespaces)

                    return !trimmed.isEmpty && trimmed != "•"

                }, id: \.self) { line in

                    if line.starts(with: "•") {

                        PrivacyBulletPoint(text: String(line))

                    } else {

                        Text(line)

                            .font(.subheadline)

                            .foregroundColor(.primary)

                            .lineSpacing(4)

                    }

                }

            }

        }

    }

    // Dynamically choose an SF Symbol based on the section title

    private func iconName(for title: String) -> String {

        switch title {

        case "How Momcare+ Works":

            return "heart.text.square" // Represents care and guidance

        case "What Information We Collect":

            return "tray.full" // Represents data collection

        case "Why We Collect Your Data":

            return "chart.bar.doc.horizontal" // Represents data usage and insights

        case "How We Protect Your Data":

            return "shield.checkerboard" // Represents security and protection

        case "Your Privacy Rights":

            return "person.crop.circle.badge.checkmark" // Represents user rights

        default:

            return "doc.text" // Default icon

        }

    }

}

struct PrivacyBulletPoint: View {

    let text: String

    var body: some View {

        HStack(alignment: .top, spacing: 8) {

            Text("•")

                .font(.subheadline)

            Text(text.dropFirst(1)) // Removes the leading "•" from the content

                .font(.subheadline)

                .foregroundColor(.primary)

        }

    }

}

struct PrivacyPolicyView_Previews: PreviewProvider {

    static var previews: some View {

        PrivacyPolicyView()

    }

}

// MARK: - Data Models

struct PolicySectionItem: Identifiable {

    let id = UUID()

    let title: String

    let content: String

}

struct PrivacyPolicyData {

    static let allSections: [PolicySectionItem] = [

        PolicySectionItem(title: "How Momcare+ Works", content: """

        • Momcare+ helps you navigate pregnancy with peace of mind. Our features include:

        • Trimester-specific guidance delivered weekly

        • Mood, diet, hydration, symptom & exercise tracking

        • Reminders for scans, checkups, supplements, and self-care

        • Mental wellness tools like guided breathing and MoodNest

        • TrimesterFlow™ and ProgressHub™ for personalized insights and trend analysis



        To provide this experience, we collect certain information that you choose to share. Here's what we collect and why.

        """), PolicySectionItem(title: "What Information We Collect", content: """

        • Profile & Pregnancy Info: Age, due date, pregnancy start date (for trimester tracking), name (optional)

        • Health Data: Symptoms, allergies, pre-existing conditions (e.g., gestational diabetes), medical notes

        • Daily Logs: Mood, hydration, food intake, energy levels, exercise tracking

        • Reminders & Notes: Appointment entries, calendar events, scan dates (if synced with iOS calendar)



        Device & Diagnostic Data:

        • Device type, iOS version (e.g., iPhone 14, iOS 17.2)

        • App version and usage analytics

        • Crash logs and error reporting (anonymous and aggregated)

        """), PolicySectionItem(title: "Why We Collect Your Data", content: """

        • Generate weekly updates based on your pregnancy stage

        • Track diet/exercise progress and show health trends in ProgressHub

        • Send custom reminders for hydration, supplements, or medical checkups

        • Suggest calming music, exercises, and mindfulness tools

        • Enhance motivation through streaks and rewards

        • Improve app performance and reduce bugs



        We do not sell, rent, or monetize your data in any way. Ever.

        """), PolicySectionItem(title: "How We Protect Your Data", content: """

        • On-device encryption of sensitive health and mood data

        • Encrypted cloud storage via GDPR-compliant platforms (e.g., AWS, Firebase, MongoDB Atlas) if sync is enabled

        • Token-based authentication and secure APIs

        • Access controls limiting who can see your data, even internally



        You retain full ownership of your data at all times.

        """), PolicySectionItem(title: "Your Privacy Rights", content: """

        • Right to Access – See what data we’ve collected about you

        • Right to Correct – Update inaccurate or outdated profile info

        • Right to Delete – Request deletion of your entire account and associated data

        • Right to Withdraw Consent – Disable features like tracking, notifications, or cloud sync at any time

        • Right to Export – GDPR-compliant data export available upon request

        """)

    ]

}

#Preview {

    PrivacyPolicyView()

}

extension Color {

    init(hexValue: String) { // Renamed to hexValue

        let scanner = Scanner(string: hexValue)

        _ = scanner.scanString("#") // Skip the "#" if present

        var rgb: UInt64 = 0

        scanner.scanHexInt64(&rgb)

        let red = Double((rgb >> 16) & 0xFF) / 255.0

        let green = Double((rgb >> 8) & 0xFF) / 255.0

        let blue = Double(rgb & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)

    }

}
