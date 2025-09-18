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
    var reminders: [ReminderInfo] = []

    var trimester: String

    var babyFruitName: String?
    var babyFruitImageURL: String?

    var nextReminder: ReminderInfo? {
        if let first = reminders.first {
            return first
        }

        return nil
    }
}

struct PregnancyTrackerTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> TriTrackEntry {
        return TriTrackEntry(week: 0, day: 0, trimester: "")
    }

    func getSnapshot(in context: Context, completion: @escaping (TriTrackEntry) -> Void) {
        let week = SharedResourceSync.getWeek()
        let day = SharedResourceSync.getDay()
        let trimester = SharedResourceSync.getTrimester()

        let entry = TriTrackEntry(week: week, day: day, trimester: trimester)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let week = SharedResourceSync.getWeek()
        let day = SharedResourceSync.getDay()
        let trimester = SharedResourceSync.getTrimester()

        let babyFruit = SharedResourceSync.getBabyFruit(for: SharedResourceSync.getWeek())

        let entry = TriTrackEntry(week: week, day: day, trimester: trimester, babyFruitName: babyFruit?.fruitName, babyFruitImageURL: babyFruit?.fruitImageURL)

        let timeline = Timeline(entries: [entry], policy: .atEnd)

//        Task {
//            let reminders = await EventKitHandler.shared.fetchReminders()
//            entry.reminders = reminders
//        }

        completion(timeline)
    }
}
