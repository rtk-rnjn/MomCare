//
//  PregnancyTrackerTimelineProvider.swift
//  MomCare
//
//  Created by Ritik Ranjan on 25/07/25.
//

import WidgetKit

struct TriTrackEntry: TimelineEntry {
    let date: Date = .init()
    let week: Int
    let day: Int
}

struct PregnancyTrackerTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> TriTrackEntry {
        return TriTrackEntry(week: 0, day: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (TriTrackEntry) -> Void) {
        let week = SharedResourceSync.getWeek()
        let day = SharedResourceSync.getDay()

        let entry = TriTrackEntry(week: week, day: day)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let week = SharedResourceSync.getWeek()
        let day = SharedResourceSync.getDay()

        let entry = TriTrackEntry(week: week, day: day)

        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}
