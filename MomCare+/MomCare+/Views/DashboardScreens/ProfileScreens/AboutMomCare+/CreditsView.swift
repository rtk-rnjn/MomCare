

import SwiftUI

private let textPrimary: Color = .init(red: 0.1, green: 0.1, blue: 0.1)
private let textSecondary: Color = .init(red: 0.4, green: 0.4, blue: 0.4)
private let imagePlaceholderBackground: Color = .init(UIColor.systemGray5)
private let imagePlaceholderForeground: Color = .init(UIColor.systemGray2)
private let brandPink: Color = .init(red: 146 / 255, green: 67 / 255, blue: 80 / 255)
private let borderColor: Color = .init(UIColor.systemGray5)

struct CreditsView: View {

    // MARK: Internal

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Our Team")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(brandPink)

                    LazyVGrid(columns: teamGridColumns, spacing: 20) {
                        ForEach(CreditsData.teamMembers) { member in
                            TeamMemberCard(imageName: member.imageName, name: member.name, role: member.role)
                        }
                    }

                    Text("Guidance & Mentorship")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(brandPink)
                        .padding(.top, 24)

                    VStack(spacing: 16) {
                        ForEach(CreditsData.mentors) { credit in
                            CreditListCard(name: credit.name, description: credit.description)
                        }
                    }

                    Text("Special Thanks")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(brandPink)
                        .padding(.top, 24)

                    VStack(spacing: 16) {
                        ForEach(CreditsData.specialThanks) { credit in
                            CreditListCard(name: credit.name, description: credit.description)
                        }
                    }

                    Text("We're grateful to everyone who helped make MomCare+ possible.")
                        .font(.caption)
                        .foregroundColor(textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 32)
                        .padding(.bottom, 20)
                }
                .padding(.horizontal, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Private

    private let teamGridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]
}

struct TeamMemberCard: View {
    let imageName: String?
    let name: String
    let role: String

    var body: some View {
        VStack(spacing: 12) {
            if let imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 90, height: 90)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(imagePlaceholderBackground)
                    .frame(width: 90, height: 90)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.largeTitle)
                            .foregroundColor(imagePlaceholderForeground)
                    )
            }

            VStack(spacing: 2) {
                Text(name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(textPrimary)

                Text(role)
                    .font(.caption)
                    .foregroundColor(textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 8)
        .background(.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(borderColor, lineWidth: 1)
        )
    }
}

struct CreditListCard: View {
    let name: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(textPrimary)

            Text(description)
                .font(.subheadline)
                .foregroundColor(textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: 1)
        )
    }
}

struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreditsView()
        }
    }
}
