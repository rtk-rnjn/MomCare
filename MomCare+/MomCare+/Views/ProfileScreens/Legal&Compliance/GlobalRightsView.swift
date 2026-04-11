import SwiftUI

struct GlobalRightsView: View {
    // MARK: Internal

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(hex: "FFFFFF").opacity(0.12))
                            .frame(width: 60, height: 60)
                        Image(systemName: "hand.raised.fill")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(accentColor)
                    }
                    .accessibilityHidden(true)

                    Text("gdpr_header_title")
                        .font(.title.weight(.semibold))
                        .tracking(-0.5)
                        .multilineTextAlignment(.center)
                        .lineSpacing(0)
                        .accessibilityAddTraits(.isHeader)

                    Text("gdpr_header_subtitle")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)
                .padding(.bottom, 8)

                Divider()

                VStack(alignment: .leading, spacing: 24) {
                    ForEach(rights) { right in
                        GDPRRightView(
                            iconName: right.iconName,
                            title: right.title,
                            description: right.description,
                            accentColor: accentColor
                        )

                        if right.id != rights.last?.id {
                            Divider()
                        }
                    }
                }
                VStack(alignment: .center, spacing: 16) {
                    Text("gdpr_exercise_rights_title")
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibilityAddTraits(.isHeader)

                    Text("gdpr_exercise_rights_body")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Text("support.momcare@vision-labs.site")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(accentColor)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Capsule())
                        .accessibilityLabel(String(localized: "gdpr_contact_email_label"))
                }
                .padding(.vertical, 24)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    // MARK: Private

    private let accentColor: Color = .init("primaryAppColor")
    private let rights: [GDPRRightItem] = GDPRData.allRights
}

struct GDPRRightView: View {
    let iconName: String
    let title: String
    let description: String
    let accentColor: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundStyle(accentColor)
                .frame(width: 24, alignment: .center)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .accessibilityAddTraits(.isHeader)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineSpacing(4)
            }
        }
    }
}
