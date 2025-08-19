import SwiftUI

struct GlobalRightsView: View {
    
    // MARK: Private

    private let accentColor: Color = .init(hex: "924350")
    private let rights: [GDPRRightItem] = GDPRData.allRights

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

struct GlobalRightsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GlobalRightsView()
        }
    }
}
