import Combine
import EventKit
import SwiftUI

private let eventIdentifier = "com.momcareplus.tritrack.calendar"
private let reminderIdentifier = "com.momcareplus.tritrack.reminders"

class EventKitHandler: ObservableObject {

    // MARK: Internal

    @Published var events: [EKEvent] = []
    @Published var upcommingEvents: [EKEvent] = []
    @Published var mostRecentEvent: EKEvent?

    @Published var reminders: [EKReminder] = []
    @Published var upcommingReminders: [EKReminder] = []
    @Published var eventStore: EKEventStore = .init()

    func startObservingEventStore() {
        NotificationCenter.default.publisher(for: .EKEventStoreChanged)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { _ in
                self.reloadEvents()
            }
            .store(in: &cancellables)
    }

    func reloadEvents() {
        try? fetchAllEvents()
        try? fetchAllReminders()
    }

    func getCalendar(with identifierKey: String) -> EKCalendar? {
        if let calendar = eventStore.calendar(withIdentifier: identifierKey) {
            return calendar
        }

        return nil
    }

    func createOrGetCalendar(identifierKey: String, eventType: EKEntityType, title: String, defaultCalendar: EKCalendar?) throws -> EKCalendar {
        let identifier: String? = database.get(identifierKey)

        if let identifier, let calendar = getCalendar(with: identifier) {
            return calendar
        }

        let newCalendar = EKCalendar(for: eventType, eventStore: eventStore)
        newCalendar.title = title
        if let localSource = eventStore.sources.first(where: { $0.sourceType == .local }) {
            newCalendar.source = localSource
        } else {
            newCalendar.source = defaultCalendar?.source
        }

        database.set(newCalendar.calendarIdentifier, forKey: identifierKey)
        try eventStore.saveCalendar(newCalendar, commit: true)

        return newCalendar
    }

    func fetchAppointments(selectedDate: Date) throws {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: selectedDate)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!

        let predicate = try eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [createOrGetEventCalendar()])
        events = eventStore.events(matching: predicate)
    }

    func fetchReminders(startDate _: Date) throws {
        let predicate = try eventStore.predicateForReminders(in: [createOrGetReminderCalendar()])
        eventStore.fetchReminders(matching: predicate) { reminders in
            DispatchQueue.main.async {
                self.reminders = reminders?.filter { reminder in
                    if let dueDate = reminder.dueDateComponents?.date {
                        return Calendar.current.isDate(dueDate, inSameDayAs: Date())
                    }
                    return false
                } ?? []
            }
        }
    }

    func editReminder(reminder _: EKReminder) {}

    func fetchAllReminders() throws {
        let predicate = try eventStore.predicateForReminders(in: [createOrGetReminderCalendar()])
        eventStore.fetchReminders(matching: predicate) { reminders in
            DispatchQueue.main.async {
                self.upcommingReminders = reminders?.filter { reminder in
                    if let dueDate = reminder.dueDateComponents?.date {
                        return dueDate >= Date()
                    }
                    return false
                } ?? []
            }
        }
    }

    func fetchAllEvents() throws {
        let predicate = try eventStore.predicateForEvents(withStart: Date(), end: Date.distantFuture, calendars: [createOrGetEventCalendar()])
        let events = eventStore.events(matching: predicate)
        upcommingEvents = events.filter { $0.startDate >= Date() }
        mostRecentEvent = upcommingEvents.sorted { $0.startDate <= $1.startDate }.first
    }

    func createOrGetEventCalendar() throws -> EKCalendar {
        try createOrGetCalendar(identifierKey: eventIdentifier, eventType: .event, title: "MomCare - TriTrack Calendar", defaultCalendar: eventStore.defaultCalendarForNewEvents)
    }

    func createOrGetReminderCalendar() throws -> EKCalendar {
        try createOrGetCalendar(identifierKey: reminderIdentifier, eventType: .reminder, title: "MomCare - TriTrack Reminders", defaultCalendar: eventStore.defaultCalendarForNewReminders())
    }

    func createEvent(title: String, startDate: Date, endDate: Date, isAllDay: Bool = false, notes: String? = nil, recurrenceRules _: [EKRecurrenceRule]? = nil, location: String? = nil, structuredLocaltion: EKStructuredLocation? = nil, alarm: EKAlarm? = nil) throws -> EKEvent {
        let event = EKEvent(eventStore: eventStore)

        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.isAllDay = isAllDay
        event.notes = notes
        event.location = location
        event.structuredLocation = structuredLocaltion
        event.calendar = try createOrGetEventCalendar()

        if let alarm {
            event.addAlarm(alarm)
        }

        try eventStore.save(event, span: .thisEvent, commit: true)

        return event
    }

    func createReminder(title: String, notes: String?, dueDateComponents: DateComponents, recurrenceRules: [EKRecurrenceRule]?) throws {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.notes = notes
        reminder.dueDateComponents = dueDateComponents
        reminder.calendar = try createOrGetReminderCalendar()
        if let recurrenceRules {
            reminder.recurrenceRules = recurrenceRules
        }

        try eventStore.save(reminder, commit: true)
    }

    // MARK: Private

    private var cancellables: Set<AnyCancellable> = []

    private let database: Database = .init()

}
