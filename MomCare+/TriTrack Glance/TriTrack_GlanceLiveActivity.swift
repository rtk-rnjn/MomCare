//
//  TriTrack_GlanceLiveActivity.swift
//  TriTrack Glance
//
//  Created by Aryan singh on 19/02/26.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct TriTrack_GlanceAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        /// Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    /// Fixed non-changing properties about your activity go here!
    var name: String
}

struct TriTrack_GlanceLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TriTrack_GlanceAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

private extension TriTrack_GlanceAttributes {
    static var preview: TriTrack_GlanceAttributes {
        TriTrack_GlanceAttributes(name: "World")
    }
}

private extension TriTrack_GlanceAttributes.ContentState {
    static var smiley: TriTrack_GlanceAttributes.ContentState {
        TriTrack_GlanceAttributes.ContentState(emoji: "😀")
    }

    static var starEyes: TriTrack_GlanceAttributes.ContentState {
        TriTrack_GlanceAttributes.ContentState(emoji: "🤩")
    }
}

#Preview("Notification", as: .content, using: TriTrack_GlanceAttributes.preview) {
    TriTrack_GlanceLiveActivity()
} contentStates: {
    TriTrack_GlanceAttributes.ContentState.smiley
    TriTrack_GlanceAttributes.ContentState.starEyes
}
