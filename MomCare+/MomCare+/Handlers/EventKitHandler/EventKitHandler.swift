import Combine
import EventKit
import SwiftUI

enum CalendarConfiguration {
    enum Identifier {
        static let event = "com.momcareplus.tritrack.calendar"
        static let reminder = "com.momcareplus.tritrack.reminders"
    }

    enum Title {
        static let event = "MomCare - TriTrack Calendar"
        static let reminder = "MomCare - TriTrack Reminders"
    }
}

@MainActor
final class EventKitHandler: ObservableObject {
    // MARK: Internal

    @Published var events: [EKEvent] = []
    @Published var allEvents: [EKEvent] = []
    @Published var onGoingOrMostRecentUpcomingEvent: EKEvent?

    @Published var reminders: [EKReminder] = []
    @Published var allReminders: [EKReminder] = []
    @Published var allIncompleteReminders: [EKReminder] = []
    @Published var allCompletedReminders: [EKReminder] = []

    @Published var eventStore: EKEventStore = .init()

    func requestAccess(for type: EKEntityType) async throws -> Bool {
        switch type {
        case .reminder:
            let success = try await eventStore.requestFullAccessToReminders()
            _ = try createOrGetReminderCalendar()
            return success

        case .event:
            let success = try await eventStore.requestFullAccessToEvents()
            _ = try createOrGetEventCalendar()
            return success

        @unknown default:
            return false
        }
    }

    func getCalendar(with identifier: String) -> EKCalendar? {
        eventStore.calendar(withIdentifier: identifier)
    }

    func createOrGetEventCalendar() throws -> EKCalendar {
        try createOrGetCalendar(
            entityType: .event,
            identifierKey: CalendarConfiguration.Identifier.event,
            title: CalendarConfiguration.Title.event,
            defaultSource: eventStore.defaultCalendarForNewEvents
        )
    }

    func createOrGetReminderCalendar() throws -> EKCalendar {
        try createOrGetCalendar(
            entityType: .reminder,
            identifierKey: CalendarConfiguration.Identifier.reminder,
            title: CalendarConfiguration.Title.reminder,
            defaultSource: eventStore.defaultCalendarForNewReminders()
        )
    }

    func twoYearDateRange() -> (start: Date, end: Date) {
        let now = Date()
        let start = Calendar.current.date(byAdding: .year, value: -2, to: now) ?? now
        let end = Calendar.current.date(byAdding: .year, value: 2, to: now) ?? now
        return (start, end)
    }

    // MARK: Private

    private func createOrGetCalendar(
        entityType: EKEntityType,
        identifierKey _: String,
        title: String,
        defaultSource: EKCalendar?
    ) throws -> EKCalendar {
        let storedIdentifier: String? = Database.shared[.calendarIdentifier(entityType)]

        if let id = storedIdentifier, let existing = getCalendar(with: id) {
            return existing
        }

        let newCalendar = EKCalendar(for: entityType, eventStore: eventStore)
        newCalendar.title = title
        newCalendar.source = defaultSource?.source

        try eventStore.saveCalendar(newCalendar, commit: true)
        Database.shared[.calendarIdentifier(entityType)] = newCalendar.calendarIdentifier

        return newCalendar
    }
}
