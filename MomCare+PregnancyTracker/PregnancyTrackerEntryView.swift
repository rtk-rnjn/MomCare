//
//  PregnancyTrackerEntryView.swift
//  MomCare
//
//  Created by Ritik Ranjan on 25/07/25.
//

import SwiftUI
import WidgetKit

struct PregnancyTrackerEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily

    var entry: PregnancyTrackerTimelineProvider.Entry

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallPregnancyWidgetView(entry: entry)
        case .systemMedium:
            MediumPregnancyWidgetView(entry: entry)
        case .systemLarge:
            LargePregnancyWidgetView(entry: entry)
        default:
            SmallPregnancyWidgetView(entry: entry)
        }
    }
}
