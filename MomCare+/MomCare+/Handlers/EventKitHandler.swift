import Combine
import EventKit
import SwiftUI

private let eventIdentifier = "com.momcareplus.tritrack.calendar"
private let reminderIdentifier = "com.momcareplus.tritrack.reminders"

@MainActor
final class EventKitHandler: ObservableObject {

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

    private func reminderMatchesDate(_ reminder: EKReminder, date: Date) -> Bool {
        
        let calendar = Calendar.current
        
        let startDateComponents = reminder.startDateComponents ?? reminder.dueDateComponents
        guard let startDate = startDateComponents?.date else { return false }
        
        for rule in reminder.recurrenceRules ?? [] {
            
            if let end = rule.recurrenceEnd?.endDate, date > end {
                continue
            }
            
            if date < startDate {
                continue
            }
            
            switch rule.frequency {
                
            case .daily:
                
                let days = calendar.dateComponents([.day], from: startDate, to: date).day ?? 0
                if days % rule.interval == 0 {
                    return true
                }
                
            case .weekly:
                
                let weeks = calendar.dateComponents([.weekOfYear], from: startDate, to: date).weekOfYear ?? 0
                guard weeks % rule.interval == 0 else { continue }
                
                let weekday = calendar.component(.weekday, from: date)
                
                if let weekdays = rule.daysOfTheWeek {
                    if weekdays.contains(where: { $0.dayOfTheWeek.rawValue == weekday }) {
                        return true
                    }
                } else {
                    let startWeekday = calendar.component(.weekday, from: startDate)
                    if weekday == startWeekday {
                        return true
                    }
                }
                
            case .monthly:
                
                let months = calendar.dateComponents([.month], from: startDate, to: date).month ?? 0
                guard months % rule.interval == 0 else { continue }
                
                let startDay = calendar.component(.day, from: startDate)
                let dateDay = calendar.component(.day, from: date)
                
                if startDay == dateDay {
                    return true
                }
                
            case .yearly:
                
                let years = calendar.dateComponents([.year], from: startDate, to: date).year ?? 0
                guard years % rule.interval == 0 else { continue }
                
                let startMonth = calendar.component(.month, from: startDate)
                let startDay = calendar.component(.day, from: startDate)
                
                let dateMonth = calendar.component(.month, from: date)
                let dateDay = calendar.component(.day, from: date)
                
                if startMonth == dateMonth && startDay == dateDay {
                    return true
                }
                
            @unknown default:
                continue
            }
        }
        
        if let dueDate = reminder.dueDateComponents?.date {
            return calendar.isDate(dueDate, inSameDayAs: date)
        }
        return calendar.isDate(startDate, inSameDayAs: date)
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

}
