import SwiftUI
import EventKit

struct TriTrackAllRemindersView: View {

    // MARK: Internal

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(Array(groupedReminders.enumerated()), id: \.offset) { index, section in
                    let isToday: Bool = {
                        guard let date = section.date else { return false }
                        return Calendar.current.isDate(date, inSameDayAs: today)
                    }()
                    let isPast: Bool = {
                        guard let date = section.date else { return false }
                        return date < today
                    }()

                    Section {
                        ForEach(section.reminders, id: \.calendarItemIdentifier) { reminder in
                            ReminderRow(reminder: reminder, showDetails: showDetails)
                                .onTapGesture {
                                    selectedReminder = EKCalendarItemWrapper(item: reminder)
                                }
                        }
                    } header: {
                        ReminderSectionHeader(date: section.date, isToday: isToday, isPast: isPast)
                    }
                    .id(index)
                }
            }
            .navigationTitle("All Reminders")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedReminder, onDismiss: {
                fetchReminders()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let idx = todaySectionIndex {
                        proxy.scrollTo(idx, anchor: .top)
                    }
                }
            }) { itemWrapper in
                if let reminder = itemWrapper.item as? EKReminder {
                    EKReminderView(reminder: reminder, selectedDate: $today)
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
                    .accessibilityLabel(showDetails ? "Switch to compact view" : "Switch to detailed view")
                    .accessibilityHint("Toggles the amount of detail shown for each reminder")
                }
            }
            .overlay {
                if eventKitHandler.allReminders.isEmpty {
                    ContentUnavailableView(
                        "No Reminders",
                        systemImage: "checklist",
                        description: Text("You don't have any reminders.")
                    )
                }
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage ?? "An unexpected error occurred.")
            }
            .onAppear {
                fetchReminders()
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
    @State private var selectedReminder: EKCalendarItemWrapper?
    @State private var showErrorAlert = false
    @State private var alertMessage: String?

    @State private var today = Calendar.current.startOfDay(for: Date())

    private var groupedReminders: [(date: Date?, reminders: [EKReminder])] {
        let withDue = eventKitHandler.allReminders.filter { $0.dueDateComponents != nil }
        let withoutDue = eventKitHandler.allReminders.filter { $0.dueDateComponents == nil }

        let grouped = Dictionary(grouping: withDue) { reminder -> Date in
            let comps = reminder.dueDateComponents!
            let date = Calendar.current.date(from: comps) ?? Date()
            return Calendar.current.startOfDay(for: date)
        }

        var sections: [(date: Date?, reminders: [EKReminder])] = grouped
            .map { (date: Optional($0.key), reminders: $0.value.sorted { lhs, rhs in
                let lDate = Calendar.current.date(from: lhs.dueDateComponents!) ?? Date()
                let rDate = Calendar.current.date(from: rhs.dueDateComponents!) ?? Date()
                return lDate < rDate
            }) }
            .sorted { ($0.date ?? .distantFuture) < ($1.date ?? .distantFuture) }

        if !withoutDue.isEmpty {
            sections.append((date: nil, reminders: withoutDue))
        }

        return sections
    }

    private var todaySectionIndex: Int? {
        groupedReminders.firstIndex(where: {
            guard let date = $0.date else { return false }
            return Calendar.current.isDate(date, inSameDayAs: today)
        }) ?? groupedReminders.firstIndex(where: {
            guard let date = $0.date else { return false }
            return date >= today
        })
    }

    private func fetchReminders() {
        do {
            try eventKitHandler.fetchAllReminders()
        } catch {
            alertMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

}

enum ReminderRowStatus {
    case past
    case pastRecurring
    case future
    case futureRecurring
    case futureRecurringWithEnd
    case today

    // MARK: Lifecycle

    init(reminder: EKReminder, now: Date = Date()) {
        guard let dueDate = reminder.dueDateComponents?.date else {
            self = .future
            return
        }

        let hasRecurrence = !(reminder.recurrenceRules ?? []).isEmpty
        let hasRecurrenceEnd = reminder.recurrenceRules?.contains { $0.recurrenceEnd != nil } ?? false

        if Calendar.current.isDate(dueDate, inSameDayAs: now) {
            self = .today
        } else if dueDate < now {
            self = hasRecurrence ? .pastRecurring : .past
        } else if hasRecurrence {
            self = hasRecurrenceEnd ? .futureRecurringWithEnd : .futureRecurring
        } else {
            self = .future
        }
    }

    // MARK: Internal

    var indicatorColor: Color {
        switch self {
        case .past: return .red
        case .pastRecurring: return .orange
        case .today: return Color.CustomColors.mutedRaspberry
        case .future: return Color(.systemGray4)
        case .futureRecurring: return .blue
        case .futureRecurringWithEnd: return .purple
        }
    }

    var labelColor: Color {
        switch self {
        case .past: return .red
        case .pastRecurring: return .orange
        case .today: return Color.CustomColors.mutedRaspberry
        case .future: return .secondary
        case .futureRecurring: return .blue
        case .futureRecurringWithEnd: return .purple
        }
    }
}

struct ReminderSectionHeader: View {
    let date: Date?
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

            if let date {
                Text(date.formatted(
                    Date.FormatStyle()
                        .weekday(.wide)
                        .day()
                        .month(.wide)
                ))
                .font(.headline)
                .textCase(nil)
                .foregroundStyle(isPast && !isToday ? .tertiary : .primary)
            } else {
                Text("No Due Date")
                    .font(.headline)
                    .textCase(nil)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel({
            if isToday { return "Today" }
            if let date { return date.formatted(Date.FormatStyle().weekday(.wide).day().month(.wide)) }
            return "No due date"
        }())
        .accessibilityAddTraits(.isHeader)
    }
}

struct ReminderRow: View {

    // MARK: Lifecycle

    init(reminder: EKReminder, showDetails: Bool) {
        self.reminder = reminder
        self.showDetails = showDetails
        _isCompleted = State(initialValue: reminder.isCompleted)
    }

    // MARK: Internal

    let reminder: EKReminder
    let showDetails: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {

            // Status indicator + line
            VStack(spacing: 0) {
                Button {
                    if reduceMotion {
                        toggleCompletion()
                    } else {
                        withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.85)) {
                            toggleCompletion()
                        }
                    }
                } label: {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(
                            isCompleted ? .green : status.indicatorColor
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isCompleted ? "Mark as incomplete" : "Mark as complete")
                .accessibilityHint("Toggles the completion status of this reminder")
                .accessibilityAddTraits(.isButton)

                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 1)
            }
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: showDetails ? 5 : 0) {

                // Title row
                HStack(spacing: 6) {
                    Text(reminder.title ?? "Untitled")
                        .font(.headline)
                        .foregroundStyle(
                            isCompleted
                            ? .teal
                            : status.labelColor
                        )
                        .strikethrough(isCompleted)

                    Spacer()

                    // Recurrence badges
                    if showDetails {
                        if hasRecurrence {
                            Image(systemName: hasRecurrenceEnd ? "repeat.1" : "repeat")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(status.labelColor)
                        }

                        if !priorityIcon.isEmpty {
                            Image(systemName: priorityIcon)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(priorityColor)
                        }
                    }

                    Circle()
                        .fill(reminderColor)
                        .frame(width: 8, height: 8)
                }

                if showDetails {

                    // Time + relative timer
                    if let time = timeLabel, let dueDate = reminder.dueDateComponents?.date {
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.caption2)
                                .foregroundStyle(status.labelColor)

                            Text(time)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text("·")
                                .foregroundStyle(.tertiary)

                            Text(dueDate, style: .relative)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(status.labelColor.opacity(0.8))
                                .monospacedDigit()
                                .lineLimit(1)
                        }
                    }

                    // Priority
                    if let priority = priorityLabel {
                        HStack(spacing: 5) {
                            Image(systemName: priorityIcon)
                                .font(.caption2)
                                .foregroundStyle(priorityColor)
                            Text(priority + " Priority")
                                .font(.caption)
                                .foregroundStyle(priorityColor)
                        }
                    }

                    // Location
                    if let location = reminder.location, !location.isEmpty {
                        HStack(spacing: 5) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(location)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Alarm
                    if let alarm = alarmLabel {
                        HStack(spacing: 5) {
                            Image(systemName: "bell")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(alarm)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Notes
                    if let notes = reminder.notes, !notes.isEmpty {
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
                    if let url = reminder.url {
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
                }
            }
            .padding(.vertical, showDetails ? 8 : 6)
        }
        .opacity(isCompleted ? 0.5 : 1.0)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Double tap to view reminder details")
        .accessibilityAddTraits(.isButton)
    }

    // MARK: Private

    @State private var isCompleted: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var status: ReminderRowStatus { ReminderRowStatus(reminder: reminder) }

    private var reminderColor: Color {
        Color(reminder.calendar.cgColor ?? UIColor.systemOrange.cgColor)
    }

    private var priorityLabel: String? {
        switch reminder.priority {
        case 1: return "High"
        case 5: return "Medium"
        case 9: return "Low"
        default: return nil
        }
    }

    private var priorityColor: Color {
        switch reminder.priority {
        case 1: return .red
        case 5: return .orange
        case 9: return .blue
        default: return .secondary
        }
    }

    private var priorityIcon: String {
        switch reminder.priority {
        case 1: return "exclamationmark.3"
        case 5: return "exclamationmark.2"
        case 9: return "exclamationmark"
        default: return ""
        }
    }

    private var timeLabel: String? {
        guard let comps = reminder.dueDateComponents,
              comps.hour != nil, comps.minute != nil,
              let date = Calendar.current.date(from: comps) else { return nil }
        return date.formatted(date: .omitted, time: .shortened)
    }

    private var hasRecurrence: Bool {
        !(reminder.recurrenceRules ?? []).isEmpty
    }

    private var hasRecurrenceEnd: Bool {
        reminder.recurrenceRules?.contains { $0.recurrenceEnd != nil } ?? false
    }

    private var alarmLabel: String? {
        guard let alarms = reminder.alarms, !alarms.isEmpty else { return nil }
        let descriptions = alarms.compactMap { alarm -> String? in
            if let absoluteDate = alarm.absoluteDate {
                return absoluteDate.formatted(date: .abbreviated, time: .shortened)
            } else {
                let offset = Int(alarm.relativeOffset / 60)
                if offset == 0 { return "At time of due date" }
                let absOffset = abs(offset)
                let sign = offset < 0 ? "Before" : "After"
                if absOffset < 60 { return "\(absOffset)m \(sign)" }
                let hours = absOffset / 60
                let mins = absOffset % 60
                return mins == 0 ? "\(hours)h \(sign)" : "\(hours)h \(mins)m \(sign)"
            }
        }
        return descriptions.joined(separator: ", ")
    }

    private func toggleCompletion() {
        isCompleted.toggle()
        reminder.isCompleted = isCompleted

    }
}
