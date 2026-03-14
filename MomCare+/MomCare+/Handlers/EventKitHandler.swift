import Combine
import EventKit
import SwiftUI

private let eventIdentifier = "com.momcareplus.tritrack.calendar"
private let reminderIdentifier = "com.momcareplus.tritrack.reminders"

@MainActor
final class EventKitHandler: ObservableObject {

    // MARK: Internal

    @Published var events: [EKEvent] = []
    @Published var allEvents: [EKEvent] = []
    @Published var mostRecentEvent: EKEvent?

    @Published var reminders: [EKReminder] = []
    @Published var allReminders: [EKReminder] = []
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

    func createOrGetCalendar(identifierKey: String, eventType: EKEntityType, title: String, source calendarSource: EKCalendar?) throws -> EKCalendar {
        let identifier: String? = database.get(identifierKey)

        if let identifier, let calendar = getCalendar(with: identifier) {
            return calendar
        }

        let newCalendar = EKCalendar(for: eventType, eventStore: eventStore)
        newCalendar.title = title
        newCalendar.source = calendarSource?.source

        try eventStore.saveCalendar(newCalendar, commit: true)
        database.set(newCalendar.calendarIdentifier, forKey: identifierKey)

        return newCalendar
    }

    func fetchAppointments(selectedDate: Date) throws {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: selectedDate)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!

        let predicate = try eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [createOrGetEventCalendar()])
        events = eventStore.events(matching: predicate)
    }

    func fetchReminders(startDate: Date) throws {
        let predicate = try eventStore.predicateForReminders(in: [createOrGetReminderCalendar()])
        eventStore.fetchReminders(matching: predicate) { reminders in
            DispatchQueue.main.async {
                self.reminders = reminders?.filter { reminder in
                    self.reminderMatchesDate(reminder, date: startDate)
                } ?? []
            }
        }
    }

    func markReminder(complete: Bool, reminder: EKReminder, date: Date) throws -> EKReminder {
        reminder.isCompleted = complete
        reminder.completionDate = complete ? Date() : nil
        try eventStore.save(reminder, commit: true)
        return reminder
    }

    func deleteReminder(_ reminder: EKReminder) throws {
        try eventStore.remove(reminder, commit: true)
    }

    func updateReminder(_ updatedReminder: EKReminder) throws -> EKReminder {
        try eventStore.save(updatedReminder, commit: true)
        return updatedReminder
    }

    func fetchAllReminders() throws {
        let predicate = try eventStore.predicateForReminders(in: [createOrGetReminderCalendar()])
        eventStore.fetchReminders(matching: predicate) { reminders in
            DispatchQueue.main.async {
                self.allReminders = reminders ?? []
            }
        }
    }

    func fetchAllEvents() throws {
        let now = Date()
        let lastTwoYear = Calendar.current.date(byAdding: .year, value: -2, to: now)!
        let nextTwoYear = Calendar.current.date(byAdding: .year, value: 2, to: now)!

        // Well. We have to limit the range to 4yr, as per the docs.

        let predicate = try eventStore.predicateForEvents(withStart: lastTwoYear, end: nextTwoYear, calendars: [createOrGetEventCalendar()])
        let events = eventStore.events(matching: predicate)
        allEvents = events
        mostRecentEvent = allEvents.sorted { $0.startDate <= $1.startDate }.first
    }

    func createOrGetEventCalendar() throws -> EKCalendar {
        try createOrGetCalendar(identifierKey: eventIdentifier, eventType: .event, title: "MomCare - TriTrack Calendar", source: eventStore.defaultCalendarForNewEvents)
    }

    func createOrGetReminderCalendar() throws -> EKCalendar {
        try createOrGetCalendar(identifierKey: reminderIdentifier, eventType: .reminder, title: "MomCare - TriTrack Reminders", source: eventStore.defaultCalendarForNewReminders())
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

    func createReminder(title: String, notes: String?, dueDateComponents: DateComponents, recurrenceRules: [EKRecurrenceRule]?, alarms: [EKAlarm]? = nil, priority: EKReminderPriority? = nil) throws {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.notes = notes
        reminder.dueDateComponents = dueDateComponents
        reminder.calendar = try createOrGetReminderCalendar()
        if let recurrenceRules {
            reminder.recurrenceRules = recurrenceRules
        }
        if let alarms {
            reminder.alarms = alarms
        }
        if let priority {
            reminder.priority = Int(priority.rawValue)
        }

        try eventStore.save(reminder, commit: true)
    }

    // MARK: Private

    private var cancellables: Set<AnyCancellable> = []

    private let database: Database = .init()

    private func reminderMatchesDate(_ reminder: EKReminder, date: Date) -> Bool {

        let calendar = Calendar.current

        guard let startDate = (reminder.startDateComponents ?? reminder.dueDateComponents)?.date else {
            return false
        }

        if let rules = reminder.recurrenceRules {
            for rule in rules where matches(rule: rule, startDate: startDate, date: date, calendar: calendar) {
                return true
            }
        }

        if let dueDate = reminder.dueDateComponents?.date {
            return calendar.isDate(dueDate, inSameDayAs: date)
        }

        return calendar.isDate(startDate, inSameDayAs: date)
    }

    private func matches(
        rule: EKRecurrenceRule,
        startDate: Date,
        date: Date,
        calendar: Calendar
    ) -> Bool {

        if let end = rule.recurrenceEnd?.endDate, date > end { return false }
        if date < startDate { return false }

        switch rule.frequency {

        case .daily:
            return matchesDaily(rule: rule, startDate: startDate, date: date, calendar: calendar)

        case .weekly:
            return matchesWeekly(rule: rule, startDate: startDate, date: date, calendar: calendar)

        case .monthly:
            return matchesMonthly(rule: rule, startDate: startDate, date: date, calendar: calendar)

        case .yearly:
            return matchesYearly(rule: rule, startDate: startDate, date: date, calendar: calendar)

        @unknown default:
            return false
        }
    }

    private func matchesDaily(
        rule: EKRecurrenceRule,
        startDate: Date,
        date: Date,
        calendar: Calendar
    ) -> Bool {

        let days = calendar.dateComponents([.day], from: startDate, to: date).day ?? 0
        return days % rule.interval == 0
    }

    private func matchesWeekly(
        rule: EKRecurrenceRule,
        startDate: Date,
        date: Date,
        calendar: Calendar
    ) -> Bool {

        let weeks = calendar.dateComponents([.weekOfYear], from: startDate, to: date).weekOfYear ?? 0
        guard weeks % rule.interval == 0 else { return false }

        let weekday = calendar.component(.weekday, from: date)

        if let weekdays = rule.daysOfTheWeek {
            return weekdays.contains { $0.dayOfTheWeek.rawValue == weekday }
        }

        let startWeekday = calendar.component(.weekday, from: startDate)
        return weekday == startWeekday
    }

    private func matchesMonthly(
        rule: EKRecurrenceRule,
        startDate: Date,
        date: Date,
        calendar: Calendar
    ) -> Bool {

        let months = calendar.dateComponents([.month], from: startDate, to: date).month ?? 0
        guard months % rule.interval == 0 else { return false }

        let startDay = calendar.component(.day, from: startDate)
        let dateDay = calendar.component(.day, from: date)

        return startDay == dateDay
    }

    private func matchesYearly(
        rule: EKRecurrenceRule,
        startDate: Date,
        date: Date,
        calendar: Calendar
    ) -> Bool {

        let years = calendar.dateComponents([.year], from: startDate, to: date).year ?? 0
        guard years % rule.interval == 0 else { return false }

        let startMonth = calendar.component(.month, from: startDate)
        let startDay = calendar.component(.day, from: startDate)

        let dateMonth = calendar.component(.month, from: date)
        let dateDay = calendar.component(.day, from: date)

        return startMonth == dateMonth && startDay == dateDay
    }

}
