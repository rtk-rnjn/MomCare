//
//  EventKitHandler.swift
//  MomCare
//
//  Created by RITIK RANJAN on 17/05/25.
//

@preconcurrency import EventKit
import EventKitUI
import UIKit
import OSLog

private let logger: Logger = .init(subsystem: "com.example.MomCare", category: "EventKitHandler")

private let eventIdentifier: String = "TriTrackEvent"
private let reminderIdentifier: String = "TriTrackReminder"

struct EventInfo: Sendable {
    var eventIdentifier: String
    var calendarItemIdentifier: String
    var calendarItemExternalIdentifier: String?
    var title: String?
    var location: String?
    var notes: String?
    var url: URL?
    var startDate: Date?
    var endDate: Date
    var isAllDay: Bool
    var calendarTitle: String
    var timeZone: TimeZone?
    var availability: EKEventAvailability
}

struct ReminderInfo: Sendable {
    var reminderIdentifier: String
    var calendarItemIdentifier: String
    var calendarItemExternalIdentifier: String?
    var title: String?
    var notes: String?
    var dueDateComponents: DateComponents?
    var isCompleted: Bool
    var calendarTitle: String
    var timeZone: TimeZone?
}

actor EventKitHandler {

    // MARK: Lifecycle

    private init() {
        eventStore = EKEventStore()
    }

    // MARK: Public

    static let shared: EventKitHandler = .init()

    public private(set) var eventStore: EKEventStore = .init()

    // MARK: Internal

    @MainActor func getEventStore() async -> EKEventStore {
        do {
            try await eventStore.commit()
        } catch let error {
            logger.error("Error committing changes to event store: \(String(describing: error))")
        }

        return await eventStore
    }

    func requestAccessForEvent(completion: ((Bool) -> Void)? = nil) async {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .authorized:
            logger.info("Event Store Access: Authorized")
            completion?(true)

        case .denied, .notDetermined, .restricted:
            logger.info("Event Store Access: Not Authorized")
            let success = try? await eventStore.requestFullAccessToEvents()
            guard let success else {
                logger.error("Event store access failed")
                completion?(false)
                return
            }
            eventStore = .init()
            completion?(success)

        default:
            logger.info("Event Store Access: Unknown status")
            completion?(false)
        }
    }

    func requestAccessForReminder(completion: ((Bool) -> Void)? = nil) async {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        switch status {
        case .authorized:
            logger.info("Reminder Store Access: Authorized")
            completion?(true)

        case .denied, .notDetermined, .restricted:
            logger.info("Reminder Store Access: Not Authorized")
            let success = try? await eventStore.requestFullAccessToReminders()
            guard let success else {
                logger.error("Reminder store access failed")
                completion?(false)
                return
            }
            eventStore = .init()
            completion?(success)

        default:
            logger.info("Reminder Store Access: Unknown status")
            completion?(false)
        }
    }

    func fetchAppointments(startDate: Date? = nil, endDate: Date? = nil) -> [EventInfo] {
        let events = fetchEvents(startDate: startDate, endDate: endDate).filter { $0.notes != "Symptom event" }
        return events.map { getEventInfo(from: $0) }
    }

    func fetchAllAppointments() -> [EventInfo] {
        let now = Date()

        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: now)
        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: now)

        return fetchAppointments(startDate: startDate, endDate: endDate)
    }

    func fetchUpcomingAppointment() -> EventInfo? {
        let calendar = createOrGetEvent()
        let predicate = eventStore.predicateForEvents(withStart: Date(), end: Date().addingTimeInterval(60 * 60 * 24), calendars: [calendar])

        let events = eventStore.events(matching: predicate)
        return events.first.map { getEventInfo(from: $0) }
    }

    func fetchSymptoms(startDate: Date? = nil, endDate: Date? = nil) -> [EventInfo] {
        let events = fetchEvents(startDate: startDate, endDate: endDate)
        return events.filter { $0.notes == "Symptom event" }.map { getEventInfo(from: $0) }
    }

    func fetchAllSymptoms() -> [EventInfo] {
        let now = Date()

        let startDate = Calendar.current.date(byAdding: .month, value: -3, to: now)
        let endDate = Calendar.current.date(byAdding: .month, value: 3, to: now)

        return fetchSymptoms(startDate: startDate, endDate: endDate)
    }

    func deleteEvent(event eventInfo: EventInfo) async {
        guard let event = getEKEvent(from: eventInfo) else {
            return
        }
        do {
            try eventStore.remove(event, span: .thisEvent, commit: true)
        } catch let error {
            logger.error("Error deleting event: \(String(describing: error))")
        }
    }

    func createEvent(title: String, startDate: Date, endDate: Date, isAllDay: Bool = false, notes: String? = nil, recurrenceRules: [EKRecurrenceRule]? = nil, location: String? = nil, structuredLocaltion: EKStructuredLocation? = nil, alarm: EKAlarm? = nil) {
        let event = EKEvent(eventStore: eventStore)

        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.isAllDay = isAllDay
        event.notes = notes
        event.location = location
        event.structuredLocation = structuredLocaltion
        event.calendar = createOrGetEvent()

        if let alarm {
            event.addAlarm(alarm)
        }

        do {
            try eventStore.save(event, span: .thisEvent, commit: true)
        } catch let error {
            logger.error("Error saving event: \(String(describing: error))")
        }
    }

    func getCalendar(with identifierKey: String) -> [EKCalendar]? {
        if let calendar = eventStore.calendar(withIdentifier: identifierKey) {
            return [calendar]
        }

        return []
    }

    func createOrGetEvent() -> EKCalendar {
        return createOrGetCalendar(identifierKey: eventIdentifier, eventType: .event, title: "MomCare - TriTrack Calendar", defaultCalendar: eventStore.defaultCalendarForNewEvents)
    }

    func createOrGetReminder() -> EKCalendar {
        return createOrGetCalendar(identifierKey: reminderIdentifier, eventType: .reminder, title: "MomCare - TriTrack Reminders", defaultCalendar: eventStore.defaultCalendarForNewReminders())
    }

    func createReminder(title: String, notes: String?, dueDateComponents: DateComponents, recurrenceRules: [EKRecurrenceRule]?) {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.notes = notes
        reminder.dueDateComponents = dueDateComponents
        reminder.calendar = createOrGetReminder()
        if let recurrenceRules {
            reminder.recurrenceRules = recurrenceRules
        }

        do {
            try eventStore.save(reminder, commit: true)
        } catch let error {
            logger.error("Error saving reminder: \(String(describing: error))")
        }
    }

    func updateReminder(reminder updatedReminder: ReminderInfo) {
        guard let reminder = getEKReminder(from: updatedReminder) else {
            logger.error("Reminder not found")
            return
        }

        do {
            try eventStore.save(reminder, commit: true)
        } catch let error {
            logger.error("Error updating reminder: \(String(describing: error))")
        }
    }

    func deleteReminder(reminder: ReminderInfo?) {
        guard let reminder = getEKReminder(from: reminder) else {
            logger.error("Reminder not found")
            return
        }
        do {
            try eventStore.remove(reminder, commit: true)
        } catch let error {
            logger.error("Error deleting reminder: \(String(describing: error))")
        }
    }

    func fetchReminders(startDate: Date? = nil, endDate: Date? = nil, completionHandler: @Sendable @escaping ([ReminderInfo]) -> Void) {
        let startDate = startDate ?? Date()
        let endDate = endDate ?? Date().addingTimeInterval(60 * 60 * 24)

        let calendar = createOrGetReminder()
        let predicate = eventStore.predicateForReminders(in: [calendar])

        eventStore.fetchReminders(matching: predicate) { fetchedReminders in
            if let fetchedReminders {
                let reminders = fetchedReminders.filter { $0.dueDateComponents?.date ?? Date() >= startDate && $0.dueDateComponents?.date ?? Date() <= endDate }.map { self.getReminderInfo(from: $0) }
                completionHandler(reminders)
            }
        }
    }

    func fetchAllReminders(completionHandler: @Sendable @escaping ([ReminderInfo]) -> Void) {
        let now = Date()

        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: now)
        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: now)

        return fetchReminders(startDate: startDate, endDate: endDate, completionHandler: completionHandler)
    }

    // MARK: Private

    private func fetchEvents(startDate: Date?, endDate: Date?) -> [EKEvent] {
        let currentCalendar = Calendar.current
        let startDate = startDate ?? currentCalendar.startOfDay(for: startDate ?? Date())
        let endDate = endDate ?? currentCalendar.date(byAdding: .day, value: 1, to: startDate) ?? Date()

        let calendar = createOrGetEvent()
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])

        return eventStore.events(matching: predicate)
    }

    private func createOrGetCalendar(identifierKey: String, eventType: EKEntityType, title: String, defaultCalendar: EKCalendar?) -> EKCalendar {
        let identifier: String? = Utils.get(fromKey: identifierKey)
        if let identifier {
            let calendars = getCalendar(with: identifier)
            if let calendar = calendars?.first {
                return calendar
            }
        }

        let newCalendar = EKCalendar(for: eventType, eventStore: eventStore)
        newCalendar.title = title
        if let localSource = eventStore.sources.first(where: { $0.sourceType == .local }) {
            newCalendar.source = localSource
        } else {
            newCalendar.source = defaultCalendar?.source
        }

        UserDefaults.standard.set(newCalendar.calendarIdentifier, forKey: identifierKey)

        do {
            try eventStore.saveCalendar(newCalendar, commit: true)
        } catch let error {
            logger.error("Error saving calendar: \(String(describing: error))")
        }

        return newCalendar
    }

    private func getEventInfo(from event: EKEvent) -> EventInfo {
        return EventInfo(
            eventIdentifier: event.eventIdentifier,
            calendarItemIdentifier: event.calendarItemIdentifier,
            calendarItemExternalIdentifier: event.calendarItemExternalIdentifier,
            title: event.title,
            location: event.location,
            notes: event.notes,
            url: event.url,
            startDate: event.startDate,
            endDate: event.endDate,
            isAllDay: event.isAllDay,
            calendarTitle: event.calendar.title,
            timeZone: event.timeZone,
            availability: event.availability
        )
    }

    private func getReminderInfo(from reminder: EKReminder) -> ReminderInfo {
        return ReminderInfo(
            reminderIdentifier: reminder.calendarItemIdentifier,
            calendarItemIdentifier: reminder.calendarItemIdentifier,
            calendarItemExternalIdentifier: reminder.calendarItemExternalIdentifier,
            title: reminder.title,
            notes: reminder.notes,
            dueDateComponents: reminder.dueDateComponents,
            isCompleted: reminder.isCompleted,
            calendarTitle: reminder.calendar.title,
            timeZone: reminder.timeZone
        )
    }

    func getEKEvent(from eventInfo: EventInfo?) -> EKEvent? {
        guard let eventInfo else {
            return nil
        }
        let event = eventStore.event(withIdentifier: eventInfo.eventIdentifier)
        if let event {
            return event
        } else {
            logger.error("Event with identifier \(eventInfo.eventIdentifier) not found")
            return nil
        }
    }

    func getEKReminder(from reminderInfo: ReminderInfo?) -> EKReminder? {
        guard let reminderInfo else {
            return nil
        }

        let reminder = eventStore.calendarItem(withIdentifier: reminderInfo.reminderIdentifier) as? EKReminder

        if let reminder {
            return reminder
        } else {
            logger.error("Reminder with identifier \(reminderInfo.reminderIdentifier) not found")
            return nil
        }
    }

}

@MainActor
class EventKitHandlerDelegate: NSObject, EKEventEditViewDelegate, EKEventViewDelegate {
    var viewController: UIViewController?

    nonisolated func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        switch action {
        case .saved:
            break
        case .canceled, .deleted:
            DispatchQueue.main.async {
                controller.dismiss(animated: true)
            }

        @unknown default:
            break
        }
    }

    nonisolated func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {
        switch action {
        case .done:
            DispatchQueue.main.async {
                controller.dismiss(animated: true)
            }

        default:
            break
        }
    }

    func presentEKEventEditViewController(with eventInfo: EventInfo?) async {
        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.eventStore = await EventKitHandler.shared.getEventStore()
        eventEditViewController.event = await EventKitHandler.shared.getEKEvent(from: eventInfo)
        eventEditViewController.editViewDelegate = self

        DispatchQueue.main.async {
            self.viewController?.present(eventEditViewController, animated: true, completion: nil)
        }
    }

    func presentEKEventViewController(with eventInfo: EventInfo?) async {
        let eventViewController = EKEventViewController()
        eventViewController.event = await EventKitHandler.shared.getEKEvent(from: eventInfo)
        eventViewController.allowsEditing = true
        eventViewController.allowsCalendarPreview = true

        let navigationController = UINavigationController(rootViewController: eventViewController)
        eventViewController.delegate = self

        viewController?.present(navigationController, animated: true)
    }

}
