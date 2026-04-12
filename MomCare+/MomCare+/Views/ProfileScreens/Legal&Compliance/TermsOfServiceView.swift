import SwiftUI

struct TermsOfServiceView: View {
    // MARK: Internal

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(hex: "FFFFFF").opacity(0.12))
                            .frame(width: 60, height: 60)
                        Image(systemName: "text.page")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(accentColor)
                    }
                    .accessibilityHidden(true)

                    Text("terms_header_title")
                        .font(.title.weight(.semibold))
                        .tracking(-0.5)
                        .multilineTextAlignment(.center)
                        .lineSpacing(0)
                        .accessibilityAddTraits(.isHeader)

                    Text("terms_header_subtitle")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
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
        .padding(.horizontal)
    }

    // MARK: Private

    private let accentColor: Color = .init("primaryAppColor")
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
                    .foregroundStyle(accentColor)
                    .frame(width: 24, alignment: .center)
                    .accessibilityHidden(true)

                Text(title)
                    .font(.title3.weight(.semibold))
                    .accessibilityAddTraits(.isHeader)
            }

            Text(.init(content.trimmingCharacters(in: .whitespacesAndNewlines)))
                .font(.subheadline)
                .foregroundStyle(.primary)
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
                    .foregroundStyle(accentColor)
                    .frame(width: 24, alignment: .center)
                    .accessibilityHidden(true)
                Text("terms_eligibility_title")
                    .font(.title3.weight(.semibold))
                    .accessibilityAddTraits(.isHeader)
            }

            VStack(alignment: .leading, spacing: 10) {
                BulletPoint(text: String(localized: "terms_eligibility_bullet_1"))
                BulletPoint(text: String(localized: "terms_eligibility_bullet_2"))
                BulletPoint(text: String(localized: "terms_eligibility_bullet_3"))
            }

            Text(.init(String(localized: "terms_eligibility_footer")))
                .font(.subheadline)
                .foregroundStyle(.primary)
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
                    .foregroundStyle(accentColor)
                    .frame(width: 24, alignment: .center)
                    .accessibilityHidden(true)
                Text("terms_overview_title")
                    .font(.title3.weight(.semibold))
                    .accessibilityAddTraits(.isHeader)
            }

            Text("terms_overview_intro")
                .font(.subheadline)
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 12) {
                ServiceDetail(title: AppTab.progress.title, description: String(localized: "terms_progress_description"))
                ServiceDetail(title: AppTab.myPlan.title, description: String(localized: "terms_myplan_description"))
                ServiceDetail(title: AppTab.triTrack.title, description: String(localized: "terms_tritrack_description"))
                ServiceDetail(title: AppTab.mood.title, description: String(localized: "terms_mood_description"))
            }
        }
    }
}

struct ServiceDetail: View {
    let title: LocalizedStringKey
    let description: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            Text(description)
                .foregroundStyle(.primary)
        }
        .accessibilityElement(children: .combine)
    }
}

struct ThirdPartyServicesView: View {
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "puzzlepiece.extension.fill")
                    .font(.title2)
                    .foregroundStyle(accentColor)
                    .frame(width: 24, alignment: .center)
                    .accessibilityHidden(true)
                Text("terms_third_party_title")
                    .font(.title3.weight(.semibold))
                    .accessibilityAddTraits(.isHeader)
            }

            Text("terms_third_party_intro")
                .font(.subheadline)
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 12) {
                Text("terms_apple_frameworks")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .padding(.top, 8)

                ServiceBulletPoint(title: "HealthKit", description: String(localized: "terms_healthkit_description"))
                ServiceBulletPoint(title: "EventKit", description: String(localized: "terms_eventkit_description"))
                ServiceBulletPoint(title: "UserNotifications", description: String(localized: "terms_notifications_description"))
                ServiceBulletPoint(title: "AVFoundation & MediaPlayer", description: String(localized: "terms_avfoundation_description"))
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("terms_ai_services")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .padding(.top, 8)

                ServiceBulletPoint(title: "Generative AI (GenAI)", description: String(localized: "terms_genai_description"))
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("terms_third_party_footer_1")
                Text("terms_third_party_footer_2")
            }
            .font(.subheadline)
            .foregroundStyle(.primary)
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
                .accessibilityHidden(true)

            VStack(alignment: .leading) {
                Text(.init("**\(title)** – \(description)"))
            }
        }
        .font(.subheadline)
        .foregroundStyle(.primary)
    }
}

struct BulletPoint: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .accessibilityHidden(true)
            Text(.init(text))
        }
        .font(.subheadline)
        .foregroundStyle(.primary)
    }
}
