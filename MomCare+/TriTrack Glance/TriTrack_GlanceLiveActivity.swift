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
