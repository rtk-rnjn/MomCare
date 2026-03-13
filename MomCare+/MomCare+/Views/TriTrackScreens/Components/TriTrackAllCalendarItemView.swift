import SwiftUI
import EventKit

struct TriTrackAllCalendarItemView: View {

    // MARK: Internal

    @Binding var selectedDate: Date

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(Array(groupedEvents.enumerated()), id: \.element.date) { index, section in
                    let isPast = section.date < today
                    let isToday = Calendar.current.isDate(section.date, inSameDayAs: today)

                    Section {
                        ForEach(section.events, id: \.eventIdentifier) { event in
                            TimelineRow(event: event, isPast: isPast, showDetails: showDetails)
                                .onTapGesture {
                                    selectedEvent = EKCalendarItemWrapper(item: event)
                                }
                        }
                    } header: {
                        DateSectionHeader(date: section.date, isToday: isToday, isPast: isPast)
                    }
                    .id(index)
                }
            }
            .navigationTitle("All Events")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedEvent, onDismiss: {
                try? eventKitHandler.fetchAllEvents()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let idx = todaySectionIndex {
                        proxy.scrollTo(idx, anchor: .top)
                    }
                }
            }) { itemWrapper in
                if let event = itemWrapper.item as? EKEvent {
                    EKEventView(event: event)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.snappy) {
                            showDetails.toggle()
                        }
                    } label: {
                        Label(
                            showDetails ? "Compact" : "Detailed",
                            systemImage: showDetails ? "list.bullet" : "list.bullet.below.rectangle"
                        )
                    }
                }
            }
            .overlay {
                if eventKitHandler.allEvents.isEmpty {
                    ContentUnavailableView(
                        "No Upcoming Events",
                        systemImage: "calendar",
                        description: Text("You don't have any scheduled events.")
                    )
                }
            }
            .onAppear {
                try? eventKitHandler.fetchAllEvents()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let idx = todaySectionIndex {
                        proxy.scrollTo(idx, anchor: .top)
                    }
                }
            }
        }
    }

    // MARK: Private

    @EnvironmentObject private var eventKitHandler: EventKitHandler
    @State private var showDetails = true
    @State private var selectedEvent: EKCalendarItemWrapper?

    private let today = Calendar.current.startOfDay(for: Date())

    private var groupedEvents: [(date: Date, events: [EKEvent])] {
        let grouped = Dictionary(
            grouping: eventKitHandler.allEvents
        ) { event in
            Calendar.current.startOfDay(for: event.startDate)
        }
        return grouped
            .map { ($0.key, $0.value.sorted { $0.startDate < $1.startDate }) }
            .sorted { $0.0 < $1.0 }
    }

    private var todaySectionIndex: Int? {
        groupedEvents.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) })
            ?? groupedEvents.firstIndex(where: { $0.date >= today })
    }

}

struct DateSectionHeader: View {
    let date: Date
    let isToday: Bool
    let isPast: Bool

    var body: some View {
        HStack(spacing: 10) {
            if isToday {
                Text("TODAY")
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.CustomColors.mutedRaspberry, in: Capsule())
            }

            Text(date.formatted(
                Date.FormatStyle()
                    .weekday(.wide)
                    .day()
                    .month(.wide)
            ))
            .font(.headline)
            .textCase(nil)
            .foregroundStyle(isPast && !isToday ? .tertiary : .primary)
        }
        .padding(.vertical, 2)
    }
}

struct TimelineRow: View {

    // MARK: Internal

    let event: EKEvent
    let isPast: Bool
    let showDetails: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {

            // Timeline indicator
            VStack(spacing: 0) {
                Circle()
                    .fill(event.isAllDay ? eventColor.opacity(0.3) : eventColor)
                    .frame(width: 10, height: 10)
                    .overlay(
                        Circle().stroke(eventColor, lineWidth: event.isAllDay ? 2 : 0)
                    )
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 1)
            }
            .padding(.top, 4)

            VStack(alignment: .leading, spacing: showDetails ? 5 : 0) {

                // Title + calendar color dot
                HStack(spacing: 6) {
                    Text(event.title ?? "Untitled")
                        .font(.headline)
                        .foregroundStyle(isPast ? .secondary : .primary)
                    Spacer()
                    if event.isAllDay {
                        Text("All Day")
                            .font(.caption2)
                            .foregroundStyle(.primaryApp)
                    }
                }

                if showDetails {
                    // Time row
                    HStack(spacing: 6) {
                        Image(systemName: event.isAllDay ? "sun.max" : "clock")
                            .font(.caption2)
                            .foregroundStyle(eventColor)

                        Text(timeLabel)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if let duration = durationLabel {
                            Text("·")
                                .foregroundStyle(.tertiary)
                            Text(duration)
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }

                    // Location
                    if let location = event.location, !location.isEmpty {
                        HStack(spacing: 5) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(location)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Notes
                    if let notes = event.notes, !notes.isEmpty {
                        HStack(alignment: .top, spacing: 5) {
                            Image(systemName: "note.text")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(notes)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }

                    // URL
                    if let url = event.url {
                        HStack(spacing: 5) {
                            Image(systemName: "link")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(url.absoluteString)
                                .font(.caption)
                                .foregroundStyle(.blue)
                                .lineLimit(1)
                        }
                    }

                    // Calendar name
                    Text(event.calendar.title)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 2)
                }
            }
            .padding(.vertical, showDetails ? 8 : 6)
        }
        .opacity(isPast ? 0.5 : 1.0)
    }

    // MARK: Private

    private var eventColor: Color {
        if let cgColor = event.calendar.cgColor {
            return Color(cgColor)
        }
        return .blue
    }

    private var timeLabel: String {
        if event.isAllDay {
            return "All Day"
        }
        let start = event.startDate.formatted(date: .omitted, time: .shortened)
        let end = event.endDate.formatted(date: .omitted, time: .shortened)
        return "\(start) – \(end)"
    }

    private var durationLabel: String? {
        guard !event.isAllDay else { return nil }
        let seconds = event.endDate.timeIntervalSince(event.startDate)
        let minutes = Int(seconds / 60)
        if minutes < 60 {
            return "\(minutes)m"
        } else if minutes % 60 == 0 {
            return "\(minutes / 60)h"
        } else {
            return "\(minutes / 60)h \(minutes % 60)m"
        }
    }

}
