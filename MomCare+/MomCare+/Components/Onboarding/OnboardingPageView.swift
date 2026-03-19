import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 12) {
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 400)
                .accessibilityHidden(true)

            Text(page.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
        }
        .padding(.bottom, 22)
    }
}
