import EventKit

extension EventKitHandler {
    func fetchReminders(startDate: Date) throws {
        let predicate = try eventStore.predicateForReminders(in: [createOrGetReminderCalendar()])
        eventStore.fetchReminders(matching: predicate) { [weak self] fetched in
            guard let self else {
                return
            }

            DispatchQueue.main.async {
                self.reminders = fetched?.filter { self.reminderMatchesDate($0, date: startDate) } ?? []
            }
        }
    }

    func fetchAllReminders() throws {
        let predicate = try eventStore.predicateForReminders(in: [createOrGetReminderCalendar()])
        eventStore.fetchReminders(matching: predicate) { [weak self] fetched in
            guard let self else {
                return
            }

            DispatchQueue.main.async {
                self.allReminders = fetched ?? []
            }
        }
    }

    func fetchAllIncompleteReminders() throws {
        let (start, end) = twoYearDateRange()
        let predicate = try eventStore.predicateForIncompleteReminders(
            withDueDateStarting: start,
            ending: end,
            calendars: [createOrGetReminderCalendar()]
        )
        eventStore.fetchReminders(matching: predicate) { [weak self] fetched in
            guard let self else {
                return
            }

            DispatchQueue.main.async {
                self.allIncompleteReminders = fetched ?? []
            }
        }
    }

    func createReminder(
        title: String,
        notes: String?,
        dueDateComponents: DateComponents,
        recurrenceRules: [EKRecurrenceRule]?,
        alarms: [EKAlarm]? = nil,
        priority: EKReminderPriority? = nil
    ) throws {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.notes = notes
        reminder.dueDateComponents = dueDateComponents
        reminder.calendar = try createOrGetReminderCalendar()
        reminder.recurrenceRules = recurrenceRules
        reminder.alarms = alarms
        if let priority {
            reminder.priority = Int(priority.rawValue)
        }
        try eventStore.save(reminder, commit: true)
    }

    @discardableResult
    func markReminder(complete: Bool, reminder: EKReminder, date _: Date) throws -> EKReminder {
        reminder.isCompleted = complete
        reminder.completionDate = complete ? Date() : nil
        try eventStore.save(reminder, commit: true)
        return reminder
    }

    @discardableResult
    func updateReminder(_ reminder: EKReminder) throws -> EKReminder {
        try eventStore.save(reminder, commit: true)
        return reminder
    }

    func deleteReminder(_ reminder: EKReminder) throws {
        try eventStore.remove(reminder, commit: true)
    }

    private func reminderMatchesDate(_ reminder: EKReminder, date: Date) -> Bool {
        let calendar = Calendar.current

        guard let startDate = (reminder.startDateComponents ?? reminder.dueDateComponents)?.date else {
            return false
        }

        if let rules = reminder.recurrenceRules {
            for rule in rules where recurrenceMatches(rule: rule, startDate: startDate, date: date, calendar: calendar) {
                return true
            }
        }

        if let dueDate = reminder.dueDateComponents?.date {
            return calendar.isDate(dueDate, inSameDayAs: date)
        }

        return calendar.isDate(startDate, inSameDayAs: date)
    }

    private func recurrenceMatches(
        rule: EKRecurrenceRule,
        startDate: Date,
        date: Date,
        calendar: Calendar
    ) -> Bool {
        guard date >= startDate else {
            return false
        }

        if let endDate = rule.recurrenceEnd?.endDate, date > endDate {
            return false
        }

        switch rule.frequency {
        case .daily: return matchesDaily(rule: rule, startDate: startDate, date: date, calendar: calendar)
        case .weekly: return matchesWeekly(rule: rule, startDate: startDate, date: date, calendar: calendar)
        case .monthly: return matchesMonthly(rule: rule, startDate: startDate, date: date, calendar: calendar)
        case .yearly: return matchesYearly(rule: rule, startDate: startDate, date: date, calendar: calendar)
        @unknown default: return false
        }
    }

    private func matchesDaily(rule: EKRecurrenceRule, startDate: Date, date: Date, calendar: Calendar) -> Bool {
        let days = calendar.dateComponents([.day], from: startDate, to: date).day ?? 0
        return days % rule.interval == 0
    }

    private func matchesWeekly(rule: EKRecurrenceRule, startDate: Date, date: Date, calendar: Calendar) -> Bool {
        let weeks = calendar.dateComponents([.weekOfYear], from: startDate, to: date).weekOfYear ?? 0
        guard weeks % rule.interval == 0 else {
            return false
        }

        let weekday = calendar.component(.weekday, from: date)
        if let weekdays = rule.daysOfTheWeek {
            return weekdays.contains { $0.dayOfTheWeek.rawValue == weekday }
        }
        return weekday == calendar.component(.weekday, from: startDate)
    }

    private func matchesMonthly(rule: EKRecurrenceRule, startDate: Date, date: Date, calendar: Calendar) -> Bool {
        let months = calendar.dateComponents([.month], from: startDate, to: date).month ?? 0
        guard months % rule.interval == 0 else {
            return false
        }

        return calendar.component(.day, from: startDate) == calendar.component(.day, from: date)
    }

    private func matchesYearly(rule: EKRecurrenceRule, startDate: Date, date: Date, calendar: Calendar) -> Bool {
        let years = calendar.dateComponents([.year], from: startDate, to: date).year ?? 0
        guard years % rule.interval == 0 else {
            return false
        }

        return calendar.component(.month, from: startDate) == calendar.component(.month, from: date)
            && calendar.component(.day, from: startDate) == calendar.component(.day, from: date)
    }
}
