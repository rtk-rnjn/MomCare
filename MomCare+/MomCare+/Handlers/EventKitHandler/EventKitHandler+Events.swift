import EventKit

extension EventKitHandler {
    func fetchAppointments(selectedDate: Date) throws {
        eventStore.refreshSourcesIfNecessary()

        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: selectedDate)
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else {
            return
        }

        let predicate = try eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: [createOrGetEventCalendar()]
        )
        events = eventStore.events(matching: predicate)
    }

    func fetchAllEvents() throws {
        eventStore.refreshSourcesIfNecessary()

        let (start, end) = twoYearDateRange()
        let predicate = try eventStore.predicateForEvents(
            withStart: start,
            end: end,
            calendars: [createOrGetEventCalendar()]
        )
        let fetched = eventStore.events(matching: predicate)
        allEvents = fetched
    }

    func createEvent(
        title: String,
        startDate: Date,
        endDate: Date,
        isAllDay: Bool = false,
        notes: String? = nil,
        recurrenceRules: [EKRecurrenceRule]? = nil,
        location: String? = nil,
        structuredLocation: EKStructuredLocation? = nil,
        alarm: EKAlarm? = nil
    ) throws -> EKEvent {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.isAllDay = isAllDay
        event.notes = notes
        event.location = location
        event.structuredLocation = structuredLocation
        event.recurrenceRules = recurrenceRules
        event.calendar = try createOrGetEventCalendar()

        if let alarm {
            event.addAlarm(alarm)
        }

        try eventStore.save(event, span: .thisEvent, commit: true)
        try? fetchAllEvents()
        return event
    }

    func deleteEvent(_ event: EKEvent) throws {
        try eventStore.remove(event, span: .thisEvent, commit: true)
        try? fetchAllEvents()
    }

    var allDistinctEvents: [EKEvent] {
        var seen = Set<String>()
        return (events + allEvents).filter { seen.insert($0.calendarItemIdentifier).inserted }
    }

    var upcomingEvents: [EKEvent] {
        let now = Date()
        return allDistinctEvents
            .filter { ($0.startDate <= now && $0.endDate >= now) || $0.startDate > now }
            .sorted { $0.startDate < $1.startDate }
    }

    var onGoingOrMostRecentUpcomingEvent: EKEvent? {
        let distinct = allDistinctEvents
        let now = Date()
        if let ongoing = distinct.first(where: { $0.startDate <= now && $0.endDate >= now }) {
            return ongoing
        }
        return distinct
            .filter { $0.startDate > now }
            .min(by: { $0.startDate < $1.startDate })
    }
}
