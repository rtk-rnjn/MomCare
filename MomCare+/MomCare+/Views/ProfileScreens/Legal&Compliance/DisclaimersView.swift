import SwiftUI

struct DisclaimersView: View {
    let accentColor: Color = .init("primaryAppColor")

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.12))
                            .frame(width: 60, height: 60)
                        Image(systemName: "exclamationmark.shield")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(accentColor)
                    }
                    .accessibilityHidden(true)
                    Text("disclaimer_header_title")
                        .font(.title.weight(.semibold))
                        .tracking(-0.5)
                        .multilineTextAlignment(.center)
                        .lineSpacing(0)
                        .accessibilityAddTraits(.isHeader)

                    Text("disclaimer_header_subtitle")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)
                .padding(.bottom, 8)

                Divider()

                let disclaimers = DisclaimerData.allDisclaimers

                ForEach(disclaimers) { disclaimer in
                    DisclaimerSection(
                        icon: disclaimer.icon,
                        title: disclaimer.title,
                        content: disclaimer.content,
                        source: disclaimer.source,
                        accentColor: accentColor
                    )
                    Divider()
                }

                VStack(spacing: 16) {
                    Text("disclaimer_footer")
                        .font(.footnote)
                        .foregroundStyle(accentColor)
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
    }
}

struct DisclaimerSection: View {
    let icon: String
    let title: String
    let content: String
    var source: String?
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(accentColor)
                    .frame(width: 24, alignment: .leading)
                    .accessibilityHidden(true)

                Text(title)
                    .font(.title3.weight(.semibold))
                    .accessibilityAddTraits(.isHeader)
            }

            Text(.init(content))
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)

            if let source, !source.isEmpty {
                Text(.init(source))
                    .font(.footnote)
                    .italic()
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
    }
}
