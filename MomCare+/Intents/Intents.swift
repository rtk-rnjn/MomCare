import AppIntents

struct Intents: AppIntent {
    static var title: LocalizedStringResource {
        "Intents"
    }

    func perform() async throws -> some IntentResult {
        .result()
    }
}
