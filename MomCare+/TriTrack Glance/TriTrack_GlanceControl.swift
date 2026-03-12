import AppIntents
import SwiftUI
import WidgetKit

struct TriTrack_GlanceControl: ControlWidget {
    static let kind: String = "com.Team05.MomCare.TriTrack-Glance.Control"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: OpenMomCareIntent()) {
                Label("Open MomCare", systemImage: "heart.circle")
            }
        }
        .displayName("Open MomCare")
        .description("Quickly open the MomCare app.")
    }
}

struct OpenMomCareIntent: AppIntent {
    static let title: LocalizedStringResource = "Open MomCare"
    static let openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}
