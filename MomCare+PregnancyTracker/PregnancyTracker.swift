//
//  PregnancyTracker.swift
//  PregnancyTracker
//
//  Created by Ritik Ranjan on 25/07/25.
//

import WidgetKit
import SwiftUI

struct PregnancyTracker: Widget {
    let kind: String = "PregnancyTracker"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PregnancyTrackerTimelineProvider()) { entry in
            PregnancyTrackerEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)

        }
        .configurationDisplayName("Pregnancy Tracker Widget")
        .description("Track your pregnancy progress with this widget!")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
