import SwiftUI

struct GlobalRightsView: View {

    private let accentColor = Color(hex: "924350")

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(hex: "FFFFFF").opacity(0.12))
                                                        .frame(width: 60, height: 60)
                                                    Image(systemName: "hand.raised.fill")
                                                        .font(.system(size: 60, weight: .bold))
                                                        .foregroundColor(accentColor)
                    }

                    Text("Your Data, Your Rights, Your Trust")
                        .font(.system(size: 28, weight: .semibold, design: .default))
                            .tracking(-0.5)
                            .multilineTextAlignment(.center)
                            .lineSpacing(0)

                    Text("We are committed to safeguarding your privacy. You have the right to control your personal information, and we make it easy for you to do so.")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 8)

                VStack(alignment: .leading, spacing: 24) {
                    GDPRRightView(
                        iconName: "person.text.rectangle.fill",
                        title: "The Right to Access",
                        description: "You have the right to request a copy of the personal data we hold about you.",
                        accentColor: accentColor
                    )

                    Divider()

                    GDPRRightView(
                        iconName: "pencil.circle.fill",
                        title: "The Right to Rectification",
                        description: "If you believe any of the data we hold about you is inaccurate or incomplete, you have the right to have it corrected.",
                        accentColor: accentColor
                    )

                    Divider()

                    GDPRRightView(
                        iconName: "trash.fill",
                        title: "The Right to Erasure",
                        description: "You can request that we delete your personal data from our systems. This is also known as the 'Right to be Forgotten'.",
                        accentColor: accentColor
                    )

                    Divider()

                    GDPRRightView(
                        iconName: "pause.circle.fill",
                        title: "The Right to Restrict Processing",
                        description: "You have the right to request that we temporarily or permanently stop processing all or some of your personal data.",
                        accentColor: accentColor
                    )

                    Divider()

                    GDPRRightView(
                        iconName: "arrow.down.doc.fill",
                        title: "The Right to Data Portability",
                        description: "You can request a copy of your personal data in a common, machine-readable format to transfer to another service.",
                        accentColor: accentColor
                    )

                    Divider()

                    GDPRRightView(
                        iconName: "speaker.slash.fill",
                        title: "The Right to Object",
                        description: "You have the right to object to us processing your personal data for specific purposes, such as direct marketing.",
                        accentColor: accentColor
                    )
                }

                VStack(alignment: .center, spacing: 16) {
                    Text("How to Exercise Your Rights")
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Text("To exercise any of these rights, please send a clear request to our dedicated privacy team. We will respond to your request in a timely manner, in accordance with applicable law.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Text("privacy@momcare.com")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(accentColor)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Capsule())
                }
                .padding(.vertical, 24)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
    }
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
                .foregroundColor(accentColor)
                .frame(width: 24, alignment: .center)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.weight(.semibold))

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineSpacing(4)
            }
        }
    }
}

// --- Xcode Preview ---
struct GlobalRightsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GlobalRightsView()
        }
    }
}
