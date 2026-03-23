import AppIntents

struct LogSymptomIntent: AppIntent {

    static let title: LocalizedStringResource = "Log Symptom"
    static let description: IntentDescription = .init("Log a pregnancy symptom.")

    static let supportedModes: IntentModes = .background

    @Parameter(title: "Symptom")
    var symptom: String

    func perform() async throws -> some IntentResult {
        return .result(
            dialog: "Logged \(symptom)"
        )
    }
}
