import Foundation

struct DisclaimerItem: Identifiable {
    let id: UUID = .init()
    let icon: String
    let title: String
    let content: String
    var source: String?
}

enum DisclaimerData {
    static var allDisclaimers: [DisclaimerItem] {
        [
            DisclaimerItem(
                icon: "stethoscope",
                title: String(localized: "disclaimer_medical_title"),
                content: String(localized: "disclaimer_medical_content"),
                source: nil
            ),
            DisclaimerItem(
                icon: "lightbulb",
                title: String(localized: "disclaimer_tips_title"),
                content: String(localized: "disclaimer_tips_content"),
                source: nil
            ),
            DisclaimerItem(
                icon: "fork.knife",
                title: String(localized: "disclaimer_meals_title"),
                content: String(localized: "disclaimer_meals_content"),
                source: String(localized: "disclaimer_meals_source")
            ),
            DisclaimerItem(
                icon: "figure.walk",
                title: String(localized: "disclaimer_exercise_title"),
                content: String(localized: "disclaimer_exercise_content"),
                source: String(localized: "disclaimer_exercise_source")
            ),
            DisclaimerItem(
                icon: "chart.line.uptrend.xyaxis",
                title: String(localized: "disclaimer_baby_growth_title"),
                content: String(localized: "disclaimer_baby_growth_content"),
                source: nil
            ),
            DisclaimerItem(
                icon: "book",
                title: String(localized: "disclaimer_articles_title"),
                content: String(localized: "disclaimer_articles_content"),
                source: String(localized: "disclaimer_articles_source")
            ),
            DisclaimerItem(
                icon: "face.smiling",
                title: String(localized: "disclaimer_mood_title"),
                content: String(localized: "disclaimer_mood_content"),
                source: String(localized: "disclaimer_mood_source")
            )
        ]
    }
}
