import SwiftUI

extension WhatsNewConfiguration {
    /// Based on changes between:
    /// d4bfd7b54430d4b1e6f15b56e0409415cbfe5d88 → 8d5916847e9f1f8aeb9cf123a1e7f1fe75e09e40
    static let v1_0_1: WhatsNewConfiguration = .init(
        appVersion: "1.0.1",
        headline: "What’s New",
        subheadline: "More helpful tracking, a smoother experience, and a few exciting extras.",
        features: [
            .init(
                icon: "heart.text.square.fill",
                iconColor: .white,
                iconBackgroundColor: .pink,
                title: "Connect with Apple Health",
                description: "MomCare+ can now work with Apple Health to support symptom tracking, mood check-ins, and breathing activity."
            ),
            .init(
                icon: "lungs.fill",
                iconColor: .white,
                iconBackgroundColor: .teal,
                title: "Breathing progress that stays in sync",
                description: "Breathing sessions are now saved as mindfulness sessions, so your progress is more reliable."
            ),
            .init(
                icon: "face.smiling.fill",
                iconColor: .white,
                iconBackgroundColor: .purple,
                title: "Mood Nest updates",
                description: "A refreshed mood picker plus better recommendations—tap a mood and explore playlists made for how you feel."
            ),
            .init(
                icon: "calendar",
                iconColor: .white,
                iconBackgroundColor: .indigo,
                title: "TriTrack improvements",
                description: "Calendar and reminders are more dependable, and symptom tracking is smoother."
            ),
            .init(
                icon: "sparkles",
                iconColor: .white,
                iconBackgroundColor: .blue,
                title: "Polish & usability tweaks",
                description: "Small improvements across the app for a cleaner, more comfortable experience."
            )
        ],
        continueButtonTitle: "Continue",
        footnote: "Some features require permission for Apple Health, Calendar, or Reminders."
    )
}
