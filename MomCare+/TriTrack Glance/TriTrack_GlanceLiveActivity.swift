import ActivityKit
import SwiftUI
import WidgetKit

struct TriTrack_GlanceAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var week: Int
        var day: Int
        var trimester: String
    }

    var pregnancyStartDate: Date
}

struct TriTrack_GlanceLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TriTrack_GlanceAttributes.self) { context in
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Week \(context.state.week)")
                        .font(.headline)
                        .fontWeight(.bold)

                    Text("Day \(context.state.day)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("Trimester \(context.state.trimester)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 139 / 255, green: 69 / 255, blue: 87 / 255))
            }
            .padding(16)
            .activityBackgroundTint(Color(.systemBackground))

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Week \(context.state.week)")
                            .font(.headline)
                            .fontWeight(.bold)

                        Text("Day \(context.state.day)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 4)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text("T\(context.state.trimester)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 139 / 255, green: 69 / 255, blue: 87 / 255))
                        .padding(.trailing, 4)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    Text("Trimester \(context.state.trimester)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } compactLeading: {
                Text("W\(context.state.week)")
                    .font(.caption2)
                    .fontWeight(.bold)
            } compactTrailing: {
                Text("D\(context.state.day)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } minimal: {
                Text("\(context.state.week)")
                    .font(.caption2)
                    .fontWeight(.bold)
            }
        }
    }
}

private extension TriTrack_GlanceAttributes {
    static var preview: TriTrack_GlanceAttributes {
        TriTrack_GlanceAttributes(pregnancyStartDate: Date())
    }
}

private extension TriTrack_GlanceAttributes.ContentState {
    static var week20: TriTrack_GlanceAttributes.ContentState {
        TriTrack_GlanceAttributes.ContentState(week: 20, day: 3, trimester: "II")
    }

    static var week32: TriTrack_GlanceAttributes.ContentState {
        TriTrack_GlanceAttributes.ContentState(week: 32, day: 1, trimester: "III")
    }
}

#Preview("Notification", as: .content, using: TriTrack_GlanceAttributes.preview) {
    TriTrack_GlanceLiveActivity()
} contentStates: {
    TriTrack_GlanceAttributes.ContentState.week20
    TriTrack_GlanceAttributes.ContentState.week32
}
