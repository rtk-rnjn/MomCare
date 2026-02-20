

import SwiftUI

struct PrivacyPolicyView: View {

    // MARK: Internal

    var body: some View {
        GeometryReader { _ in
            ScrollView {
                VStack(spacing: 24) {
                    headerView
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

                    Divider()
                        .background(Color.gray.opacity(0.5))
                        .padding(.vertical, 8)

                    contactView
                        .padding(.top, 16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: Private

    private let accentColor: Color = .init("primaryAppColor")
    private let policySections: [PolicySectionItem] = PrivacyPolicyText.policySections

    private var headerView: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 60, height: 60)
                Image(systemName: "lock.shield")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(accentColor)
            }

            Text(PrivacyPolicyText.headerTitle)
                .font(.system(size: 28, weight: .semibold))
                .tracking(-0.5)
                .multilineTextAlignment(.center)
                .lineSpacing(0)

            Text(PrivacyPolicyText.headerSubtitle)
                .font(.subheadline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
    }

    private var contactView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "envelope")
                    .font(.title2)
                    .foregroundColor(accentColor)
                    .frame(width: 24, alignment: .center)

                Text(PrivacyPolicyText.contactTitle)
                    .font(.title3.weight(.semibold))
            }

            Text(PrivacyPolicyText.contactSubtitle)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineSpacing(4)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(accentColor)
                    Text(PrivacyPolicyText.contactEmail)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }

                HStack(spacing: 8) {
                    Image(systemName: "globe")
                        .foregroundColor(accentColor)
                    Text(PrivacyPolicyText.contactWebsite)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
            }

            Text(PrivacyPolicyText.contactFooter)
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundColor(accentColor)
                .padding(.top, 8)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct PolicySectionView: View {

    // MARK: Internal

    let title: String
    let content: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: iconName(for: title))
                    .font(.title2)
                    .foregroundColor(accentColor)
                    .frame(width: 24, alignment: .center)

                Text(title)
                    .font(.title3.weight(.semibold))
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(content.split(separator: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }, id: \.self) { line in
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

    // MARK: Private

    private func iconName(for title: String) -> String {
        switch title {
        case "How Momcare+ Works": "heart.text.square"
        case "What Information We Collect": "tray.full"
        case "Why We Collect Your Data": "chart.bar.doc.horizontal"
        case "How We Protect Your Data": "shield.checkerboard"
        case "Your Privacy Rights": "person.crop.circle.badge.checkmark"
        default: "doc.text"
        }
    }
}

struct PrivacyBulletPoint: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.subheadline)
            Text(text.dropFirst(1))
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    PrivacyPolicyView()
}
