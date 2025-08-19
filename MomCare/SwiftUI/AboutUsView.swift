import SwiftUI

private let appBackground = Color(UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.00))
private let brandPink = Color(red: 146/255, green: 67/255, blue: 80/255)
private let borderColor = Color(UIColor.systemGray4)
private let textPrimary = Color.primary
private let textSecondary = Color.secondary

struct AboutUsView: View {
    var body: some View {
        ZStack {
            appBackground.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                
                LazyVStack(alignment: .leading, spacing: 32) {
                    SectionView(
                        iconName: "book.closed",
                        eyebrowText: "Our Story",
                        title: "Our Story",
                        bodyText: """
                         It started with a Simple Observation.

                        It all began when our friend, Aryan, noticed something during his sister's pregnancy. She was miles away from family, and her main source of support wasn't an app, but constant phone calls back home to her mom. It was a beautiful connection, but it highlighted a huge gap.

                        He brought this thought to us—Khushi, Ritik, and Nupur. We were all part of a major innovation program by Apple and Infosys, and this idea immediately sparked a conversation. Was this a universal experience?

                        So, we dove in. Together, we spent weeks researching, talking to new mothers, and downloading every pregnancy app we could find. What we discovered was... a mess. A world of cluttered interfaces, conflicting advice, and a relentless focus on selling products. It felt like the actual person going through the journey—the mother—was an afterthought.

                        That was our "aha!" moment. The four of us, sitting together, realized we weren't just looking at a gap in the market; we were looking at a gap in care.

                        We knew we had to build something different. Something calm, beautiful, and genuinely supportive. An app that puts the mother's health and peace of mind first.

                        And that's how MomCare+ was born. From a single observation, a team discussion, and a shared mission to create the sanctuary we wished existed for every expecting mother.
                        """
                    )
                    .padding(.top, 30)
                    
                    SectionView(
                        iconName: "heart",
                        eyebrowText: "Our Mission",
                        title: "Our Mission",
                        bodyText: "To empower expecting mothers with a single, calm, and comprehensive tool for their prenatal journey, focusing on their well-being every step of the way."
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
                    .padding(.horizontal)
                    
                    Text("Crafted with care. Informed by evidence. Focused on you.")
                        .font(.footnote)
                        .foregroundColor(textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom)
                        .padding(.top, 16)

                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SectionView: View {
    let iconName: String
    let eyebrowText: String
    let title: String
    let bodyText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                Text(eyebrowText)
                Spacer()
            }
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(borderColor, lineWidth: 1))
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(textPrimary)
            
            Text(bodyText)
                .font(.body)
                .foregroundColor(textPrimary)
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
                .foregroundColor(textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100)
        .padding(8)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct AboutUsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AboutUsView()
        }
    }
}
