import SwiftUI

struct TermsOfServiceView: View {

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
                                                        Image(systemName: "text.page")
                                                            .font(.system(size: 60, weight: .bold))
                                                            .foregroundColor(accentColor)
                        }

                        Text("Good rules create a space where everyone can feel safe and respected.")
                            .font(.system(size: 28, weight: .semibold, design: .default))
                                .tracking(-0.5)
                                .multilineTextAlignment(.center)
                                .lineSpacing(0)

                        Text("Clarity is the foundation of trust. Our terms are designed to be clear, so our relationship can be strong.")
                            .font(.subheadline)
                                                    .foregroundColor(.primary)
                                                    .multilineTextAlignment(.center)
                                            }
                                            .padding(.top, 32)
                                            .padding(.bottom, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)

                    Divider()

                    ForEach(legalSections) { section in
                        switch section.type {
                        case let .standard(icon, title, content):
                            LegalSectionView(iconName: icon, title: title, content: content, accentColor: accentColor)
                        case .eligibility:
                            EligibilitySectionView(accentColor: accentColor)
                        case .overview:
                            OverviewOfServicesView(accentColor: accentColor)
                        case .thirdParty:
                            ThirdPartyServicesView(accentColor: accentColor)
                        }

                        if section.id != legalSections.last?.id {
                            Divider().padding(.vertical, 8)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))

        }

    // MARK: Private

    private let accentColor: Color = .init(hex: "924350")
    private let legalSections: [LegalSectionItem] = TermsData.allSections

    }

struct LegalSectionView: View {
    let iconName: String
    let title: String
    let content: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(accentColor)
                    .frame(width: 24, alignment: .center)

                Text(title)
                    .font(.title3.weight(.semibold))
            }

            Text(.init(content.trimmingCharacters(in: .whitespacesAndNewlines)))
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineSpacing(4)
        }
    }
}

struct EligibilitySectionView: View {
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.title2)
                    .foregroundColor(accentColor)
                    .frame(width: 24, alignment: .center)
                Text("Eligibility – Who Can Use MomCare")
                    .font(.title3.weight(.semibold))
            }

            VStack(alignment: .leading, spacing: 10) {
                BulletPoint(text: "You must be **at least 18 years old** or the legal age of majority in your country.")
                BulletPoint(text: "You must be **pregnant**, planning a pregnancy, or a caregiver/support person.")
                BulletPoint(text: "You must **agree to and comply** with these Terms of Service and our Privacy Policy.")
            }

            Text("The MomCare app is **not intended for use by children**, nor is it a tool for professional medical personnel to manage patient records.")
                .font(.subheadline)
                .foregroundColor(.primary)
                .padding(.top, 8)
        }
    }
}

struct OverviewOfServicesView: View {
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundColor(accentColor)
                    .frame(width: 24, alignment: .center)
                Text("Overview of Services")
                    .font(.title3.weight(.semibold))
            }

            Text("MomCare offers a range of tools designed to enhance your pregnancy journey:")
                .font(.subheadline)
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 12) {
                ServiceDetail(title: "ProgressHub", description: "A comprehensive summary of your daily/weekly exercise and diet progress, with daily insights and tips.")
                ServiceDetail(title: "MyPlan", description: "Personalized daily recommendations for diet and exercise based on your health input.")
                ServiceDetail(title: "TriTrack", description: "A “Me & Baby” view, highlighting your stage of pregnancy with size comparisons and week-by-week summaries.")
                ServiceDetail(title: "MoodNest", description: "A mood-based audio experience with tunes tailored to your emotional state.")
            }
        }
    }
}

struct ServiceDetail: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Text(description)
                .foregroundColor(.primary)
        }
    }
}

struct ThirdPartyServicesView: View {
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "puzzlepiece.extension.fill")
                    .font(.title2)
                    .foregroundColor(accentColor)
                    .frame(width: 24, alignment: .center)
                Text("Third-Party Services and Frameworks")
                    .font(.title3.weight(.semibold))
            }

            Text("To deliver a personalized and feature-rich experience, MomCare integrates with a number of third-party services, frameworks, and APIs. These services may handle or process certain types of data to enable app functionality.")
                .font(.subheadline)
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 12) {
                Text("Apple Frameworks & Services")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, 8)

                ServiceBulletPoint(title: "HealthKit", description: "To collect and analyze health data such as activity, steps, and other metrics, if access is granted by the user.")
                ServiceBulletPoint(title: "EventKit", description: "To allow appointment logging, calendar integration, and management of pregnancy-related reminders and events.")
                ServiceBulletPoint(title: "UserNotifications", description: "For delivering local notifications about reminders, tips, hydration alerts, exercise tracking, and more.")
                ServiceBulletPoint(title: "AVFoundation & MediaPlayer", description: "To power audio playback features in MoodNest, including mood-specific calming soundtracks.")
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("AI Services")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, 8)

                ServiceBulletPoint(title: "Generative AI (GenAI)", description: "Utilized for powering certain smart recommendations, personalized wellness suggestions, or adaptive daily tips. All outputs are generated in response to user-provided context and inputs.")
            }

            VStack(alignment: .leading, spacing: 10) {
                 Text("Use of these services is subject to their respective privacy policies and terms of use. By using MomCare, you acknowledge and consent to the processing of relevant data by these services, solely for the purposes of enhancing your experience and delivering the app’s features.")
                 Text("We do not share or sell your data to third parties for advertising or marketing purposes.")
            }
            .font(.subheadline)
            .foregroundColor(.primary)
            .padding(.top, 8)
        }
    }
}

struct ServiceBulletPoint: View {
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.subheadline)

            VStack(alignment: .leading) {
                Text(.init("**\(title)** – \(description)"))
            }
        }
        .font(.subheadline)
        .foregroundColor(.primary)
    }
}

struct BulletPoint: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(.init(text))
        }
        .font(.subheadline)
        .foregroundColor(.primary)
    }
}

struct TermsOfServiceView_Previews: PreviewProvider {
    static var previews: some View {
        TermsOfServiceView()
    }
}
