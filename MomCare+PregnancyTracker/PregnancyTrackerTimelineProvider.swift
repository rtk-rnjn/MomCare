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
    let trimester: String
    let nextReminder: String?
    let babyFruitName: String?
    let babyFruitImageURL: String?
}

struct PregnancyTrackerTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> TriTrackEntry {
        return TriTrackEntry(
            week: 11,
            day: 4,
            trimester: "I",
            nextReminder: "Take prenatal vitamin 💊",
            babyFruitName: "Bell Pepper",
            babyFruitImageURL: "https://img.icons8.com/color/96/lime.png"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TriTrackEntry) -> Void) {
        let entry = TriTrackEntry(
            week: SharedResourceSync.getWeek(),
            day: SharedResourceSync.getDay(),
            trimester: SharedResourceSync.getTrimester(),
            nextReminder: "Doctor Appointment 🩺",
            babyFruitName: "Papaya",
            babyFruitImageURL: "https://example.com/papaya.png"
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @Sendable @escaping (Timeline<TriTrackEntry>) -> Void) {
        let currentDate = Date()
        SharedResourceSync.getNextReminder { reminder in
            let babyFruit = SharedResourceSync.getBabyFruit(for: SharedResourceSync.getWeek())
            let entry = TriTrackEntry(
                week: SharedResourceSync.getWeek(),
                day: SharedResourceSync.getDay(),
                trimester: SharedResourceSync.getTrimester(),
                nextReminder: reminder,
                babyFruitName: babyFruit?.fruitName,
                babyFruitImageURL: babyFruit?.fruitImageURL
            )

            let nextRefresh = Calendar.current.date(byAdding: .hour, value: 6, to: currentDate)!
            let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
            completion(timeline)
        }
    }
}
