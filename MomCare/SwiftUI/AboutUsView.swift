import SwiftUI

private let brandPink: Color = .init(red: 146/255, green: 67/255, blue: 80/255)

private let borderColor: Color = .init(UIColor.systemGray4)

struct AboutUsView: View {

    var body: some View {

        ZStack {

            ScrollView {

                LazyVStack(alignment: .leading, spacing: 32) {

                    SectionView(

                        iconName: "book.closed", iconColor: .blue, eyebrowText: "Our Story", title: "Our Story", bodyText: """

                            The world of pregnancy apps can be a loud, cluttered, and overwhelming place. We know, because we've been there.



                            Our journey began when we saw a loved one navigating her pregnancy from miles away, relying on daily phone calls home for the trusted support she couldn't find online. This sparked a mission for us—Aryan, Khushi, Ritik, and Nupur—to ask a simple question: **What if an app could feel like a calm companion, not a marketplace?**



                            We dove into research and found that most apps were focused on selling products, while the actual person at the center of the journey—the mother—was often an afterthought. We knew we had to build a better alternative.



                            MomCare+ is our answer.



                            It was designed from the ground up to provide calm, clarity, and genuine care.



                            • Instead of clutter, we offer focus. You'll only find what you truly need: personalized meal and exercise plans, an intuitive symptom tracker, and calming audio to support your peace of mind.

                            • Instead of a sales pitch, we offer support. Our goal isn't to sell you things; it's to empower you with evidence-based tools that put your health and well-being first.

                            • Instead of being baby-focused, we are mother-centered. We believe that a healthy, supported, and celebrated mother is the foundation for everything.



                            Every feature in MomCare+ comes from a single observation, a team discussion, and a shared mission to create the app we wished existed for every expecting mother. Welcome to the calm.

                            """

                    )

                    .padding(.top, 30)

                    QuoteView()

                    SectionView(

                        iconName: "heart", iconColor: .red, eyebrowText: "Our Mission", title: "Our Mission", bodyText: "To empower expecting mothers with a single, calm, and comprehensive tool for their prenatal journey, focusing on their well-being every step of the way."

                    )

                    .padding(.top, 30)

                    HStack(spacing: 16) {

                        ValueCardView(

                            iconName: "person.fill", title: "Mother-First Focus"

                        )

                        ValueCardView(

                            iconName: "circle.grid.3x3.fill", title: "All-in-One, Clutter-Free"

                        )

                        ValueCardView(

                            iconName: "wand.and.rays", title: "Born from Experience"

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

struct SectionView: View {

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

            .font(.caption)

            .fontWeight(.medium)

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

                .font(.title)

                .fontWeight(.bold)

                .foregroundColor(brandPink.opacity(0.5))

            (

                Text("Every pregnancy has its own story, its own rhythm, its own needs. Our mission is to provide the personal, unwavering support that honors yours.")

                    .font(.title3)

                    .fontWeight(.medium)

                    .foregroundColor(brandPink)

            )

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
