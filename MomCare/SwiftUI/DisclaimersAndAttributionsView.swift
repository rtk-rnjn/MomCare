import SwiftUI

struct DisclaimersView: View {
    let accentColor = Color(hex: "924350")

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(hex: "FFFFFF").opacity(0.12))
                                                        .frame(width: 60, height: 60)
                                                    Image(systemName: "exclamationmark.shield")
                                                        .font(.system(size: 60, weight: .bold))
                                                        .foregroundColor(accentColor)
                    }
                    Text("MomCare supports you, but your doctor knows you best!")
                        .font(.system(size: 28, weight: .semibold, design: .default))
                            .tracking(-0.5)
                            .multilineTextAlignment(.center)
                            .lineSpacing(0)

                    Text("Your safety and understanding are important to us. Please review the information below before using MomCare+.")
                        .font(.subheadline)
                                                .foregroundColor(.primary)
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

                    Text("By using MomCare+, you acknowledge that you have read and understood these disclaimers.")
                        .font(.footnote)
                        .foregroundColor(accentColor)
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
                    .foregroundColor(accentColor)
                    .frame(width: 24, alignment: .leading)

                Text(title)
                    .font(.title3.weight(.semibold))
            }

            Text(.init(content))
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)

            if let source = source, !source.isEmpty {
                Text(.init(source))
                    .font(.footnote)
                    .italic()
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
    }
}

struct DisclaimersView_Previews: PreviewProvider {
    static var previews: some View {
        DisclaimersView()
    }
}
