import Foundation

struct OnboardingPage: Identifiable {
    let id: UUID = .init()
    let imageName: String
    let title: String
}

let onboardingPages: [OnboardingPage] = [
    OnboardingPage(
        imageName: "OnboardingImage1",
        title: "Personalised plans curated just for you"
    ),
    OnboardingPage(
        imageName: "OnboardingImage2",
        title: "Receive insights for every trimester"
    ),
    OnboardingPage(
        imageName: "OnboardingImage3",
        title: "Track your progress effortlessly"
    ),
    OnboardingPage(
        imageName: "OnboardingImage4",
        title: "Never miss a moment with reminders"
    )
]
