import SwiftUI

private let brandPink: Color = .init(red: 146 / 255, green: 67 / 255, blue: 80 / 255)
private let borderColor: Color = .init(UIColor.systemGray4)

struct AboutUsView: View {
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 32) {
                    AboutInfoView(
                        iconName: "book.closed",
                        iconColor: Color("primaryAppColor"),
                        eyebrowText: "Our Story",
                        title: "Our Story",
                        bodyText: AboutUs.story
                    )
                    .padding(.top, 30)

                    QuoteView()

                    AboutInfoView(
                        iconName: "heart",
                        iconColor: .red,
                        eyebrowText: "Our Mission",
                        title: "Our Mission",
                        bodyText: AboutUs.mission
                    )
                    .padding(.top, 30)

                    HStack(spacing: 16) {
                        ValueCardView(
                            iconName: "person.fill",
                            title: "Mother-First Focus"
                        )
                        ValueCardView(
                            iconName: "circle.grid.3x3.fill",
                            title: "All-in-One, Clutter-Free"
                        )
                        ValueCardView(
                            iconName: "wand.and.rays",
                            title: "Born from Experience"
                        )
                    }
                    .padding(.horizontal, 30)

                    Text("Crafted with care. Informed by evidence. Focused on you.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom)
                        .padding(.top, 16)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutInfoView: View {
    let iconName: String
    let iconColor: Color
    let eyebrowText: String
    let title: String
    let bodyText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: iconName).foregroundColor(iconColor)
                Text(eyebrowText).foregroundColor(.primary)
                Spacer()
            }
            .font(.caption.weight(.medium))
            .foregroundColor(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(borderColor, lineWidth: 1))

            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .textCase(.uppercase)

            Text(bodyText)
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(6)
        }
        .padding(.horizontal)
    }
}

struct ValueCardView: View {
    let iconName: String
    let title: String

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(brandPink.opacity(0.1))
                    .frame(width: 40, height: 40)

                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundColor(brandPink)
            }

            Text(title)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100)
        .padding(8)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(20)
    }
}

struct QuoteView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "quote.opening")
                .font(.title.weight(.bold))
                .foregroundColor(brandPink.opacity(0.5))

            Text(AboutUs.quote)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(brandPink)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
        .padding(.vertical, 24)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

struct AboutUsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AboutUsView()
        }
    }
}
