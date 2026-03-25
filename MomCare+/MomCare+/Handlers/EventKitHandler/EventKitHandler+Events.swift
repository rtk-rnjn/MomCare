import EventKit

extension EventKitHandler {
    func fetchAppointments(selectedDate: Date) throws {
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
        let (start, end) = twoYearDateRange()
        let predicate = try eventStore.predicateForEvents(
            withStart: start,
            end: end,
            calendars: [createOrGetEventCalendar()]
        )
        let fetched = eventStore.events(matching: predicate)
        allEvents = fetched
        onGoingOrMostRecentUpcomingEvent = ongoingOrNextUpcoming(from: fetched)
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
        return event
    }

    func deleteEvent(_ event: EKEvent) throws {
        try eventStore.remove(event, span: .thisEvent, commit: true)
    }

    // MARK: - Private

    private func ongoingOrNextUpcoming(from events: [EKEvent]) -> EKEvent? {
        let now = Date()
        if let ongoing = events.first(where: { $0.startDate <= now && $0.endDate >= now }) {
            return ongoing
        }
        return events
            .filter { $0.startDate > now }
            .min(by: { $0.startDate < $1.startDate })
    }
}
