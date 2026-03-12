import SwiftUI
import WidgetKit

struct TriTrackEntry: TimelineEntry {
    let date: Date
    let week: Int
    let day: Int
    let trimester: String
    let isValid: Bool
    let fruitComparison: String
    let fruitImageURL: String?
    let babyHeightCm: Double?
    let babyWeightG: Double?
}

struct TriTrackGlanceProvider: TimelineProvider {
    private let database = Database()

    func placeholder(in _: Context) -> TriTrackEntry {
        TriTrackEntry(
            date: .now,
            week: 20,
            day: 3,
            trimester: "II",
            isValid: true,
            fruitComparison: "banana",
            fruitImageURL: nil,
            babyHeightCm: 25.6,
            babyWeightG: 300
        )
    }

    func getSnapshot(in _: Context, completion: @escaping (TriTrackEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<TriTrackEntry>) -> Void) {
        let entry = makeEntry()
        let nextUpdate = Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: 24 * 60 * 60))
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func makeEntry() -> TriTrackEntry {
        guard let progress = database.pregnancyProgress(), progress.isValid else {
            return TriTrackEntry(
                date: .now,
                week: 0,
                day: 0,
                trimester: "—",
                isValid: false,
                fruitComparison: "",
                fruitImageURL: nil,
                babyHeightCm: nil,
                babyWeightG: nil
            )
        }

        let trimesterData = TriTrackData.getTrimesterData(for: progress.week)
        return TriTrackEntry(
            date: .now,
            week: progress.week,
            day: progress.day,
            trimester: progress.trimester,
            isValid: true,
            fruitComparison: trimesterData?.fruitComparison ?? "tiny embryo",
            fruitImageURL: trimesterData?.imageUri,
            babyHeightCm: trimesterData?.babyHeightInCentimeters,
            babyWeightG: trimesterData?.babyWeightInGrams
        )
    }
}

struct TriTrack_GlanceEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    let entry: TriTrackEntry

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct TriTrack_Glance: Widget {
    let kind: String = "TriTrack_Glance"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TriTrackGlanceProvider()) { entry in
            TriTrack_GlanceEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("TriTrack Glance")
        .description("Track your pregnancy progress at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

private extension TriTrackEntry {
    static var preview: TriTrackEntry {
        TriTrackEntry(
            date: .now,
            week: 20,
            day: 3,
            trimester: "II",
            isValid: true,
            fruitComparison: "banana",
            fruitImageURL: "https://img.icons8.com/emoji/48/banana-emoji.png",
            babyHeightCm: 25.6,
            babyWeightG: 300
        )
    }
}

#Preview("Small", as: .systemSmall) {
    TriTrack_Glance()
} timeline: {
    TriTrackEntry.preview
}

#Preview("Medium", as: .systemMedium) {
    TriTrack_Glance()
} timeline: {
    TriTrackEntry.preview
}

#Preview("Large", as: .systemLarge) {
    TriTrack_Glance()
} timeline: {
    TriTrackEntry.preview
}
