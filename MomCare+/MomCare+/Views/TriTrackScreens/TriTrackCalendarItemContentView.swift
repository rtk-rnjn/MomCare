import EventKit
import MapKit
import SwiftUI

enum AddMode: String, CaseIterable {
    case appointment = "Event"
    case reminder = "Reminder"
}

struct EKCalendarItemWrapper: Identifiable {
    let item: EKCalendarItem

    var id: String {
        item.calendarItemIdentifier
    }
}

struct TriTrackCalendarItemContentView: View {
    // MARK: Internal

    @Binding var selectedDate: Date
    @Binding var showingAllEvents: Bool
    @Binding var showingAllReminders: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                Section {
                    eventList
                } header: {
                    eventsHeader
                }

                Section {
                    reminderList
                } header: {
                    remindersHeader
                }
            }
            .listStyle(.plain)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
            .frame(maxWidth: .infinity)
            // Utils
            .onReceive(NotificationCenter.default.publisher(for: .EKEventStoreChanged)) { _ in
                Task { await refreshData() }
            }
            .contentMargins(.bottom, 80, for: .scrollContent)
            .sheet(isPresented: $controlState.showingAddEventSheet) {
                Task { await refreshData() }
            } content: {
                TriTrackAddCalendarItemSheetView(selectedDate: $selectedDate, selectedSegment: addMode)
                    .scrollDismissesKeyboard(.immediately)
                    .presentationDetents([.medium, .large])
            }

            .sheet(item: $selectedEvent) {
                Task { await refreshData() }
            } content: { itemWrapper in
                if let event = itemWrapper.item as? EKEvent {
                    EKEventView(event: event)
                }
            }

            .sheet(item: $selectedReminder) {
                Task { await refreshData() }
            } content: { wrapper in
                if let reminder = wrapper.item as? EKReminder {
                    EKReminderView(reminder: reminder, selectedDate: $selectedDate)
                        .interactiveDismissDisabled(true)
                }
            }
            .task { await initialLoad() }
            .onChange(of: selectedDate) { Task { await refreshData() } }
            .onAppear { Task { await refreshData() } }
            .refreshable {
                await refreshData()
            }
            .alert(
                "Delete Event?",
                isPresented: $showDeleteEventConfirmation,
                presenting: eventToDelete
            ) { event in
                Button("Cancel", role: .cancel) {
                    eventToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    deleteEvent(event)
                }
            } message: { event in
                Text("Are you sure you want to delete \"\(event.title ?? "this event")\"?")
            }
            .alert(
                "Delete Reminder?",
                isPresented: $showDeleteReminderConfirmation,
                presenting: reminderToDelete
            ) { reminder in
                Button("Cancel", role: .cancel) {
                    reminderToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    deleteReminder(reminder)
                }
            } message: { reminder in
                Text("Are you sure you want to delete \"\(reminder.title ?? "this reminder")\"?")
            }

            undoToastView
        }
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @EnvironmentObject private var eventKitHandler: EventKitHandler
    @EnvironmentObject private var controlState: ControlState
    @Environment(\.openURL) private var openURL

    @State private var addMode: AddMode = .appointment

    @State private var selectedEvent: EKCalendarItemWrapper?
    @State private var selectedReminder: EKCalendarItemWrapper?

    @State private var eventToDelete: EKEvent?
    @State private var showDeleteEventConfirmation = false

    @State private var reminderToDelete: EKReminder?
    @State private var showDeleteReminderConfirmation = false

    @State private var lastDeletedItem: DeletedItemBackup?
    @State private var showUndoToast: Bool = false
    @State private var undoTimerTask: Task<Void, Never>?

    private var isTodaySelected: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    private var displayedEvents: [EKEvent] {
        if isTodaySelected {
            Array(eventKitHandler.upcomingEvents.prefix(2))
        } else {
            eventKitHandler.events
        }
    }

    private var displayedEventsCount: Int {
        if isTodaySelected {
            eventKitHandler.upcomingEvents.count
        } else {
            eventKitHandler.events.count
        }
    }

    private var displayedReminders: [EKReminder] {
        if isTodaySelected {
            Array(eventKitHandler.upcomingIncompleteReminders.prefix(2))
        } else {
            eventKitHandler.reminders
        }
    }

    private var displayedRemindersCount: Int {
        if isTodaySelected {
            eventKitHandler.upcomingIncompleteReminders.count
        } else {
            eventKitHandler.reminders.count
        }
    }

    private var eventsHeader: some View {
        Button {
            showingAllEvents = true
        } label: {
            HStack(spacing: 6) {
                Text("Events")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("(\(displayedEventsCount))")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .contentTransition(reduceMotion ? .identity : .numericText())
                    .animation(reduceMotion ? nil : .easeInOut, value: displayedEventsCount)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("Events, \(displayedEventsCount)")
        .accessibilityHint("Shows all events")
    }

    private var remindersHeader: some View {
        Button {
            showingAllReminders = true
        } label: {
            HStack(spacing: 6) {
                Text("Reminders")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("(\(displayedRemindersCount))")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .contentTransition(reduceMotion ? .identity : .numericText())
                    .animation(reduceMotion ? nil : .easeInOut, value: displayedRemindersCount)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("Reminders, \(displayedRemindersCount)")
        .accessibilityHint("Shows all reminders")
    }

    @ViewBuilder
    private var eventList: some View {
        if displayedEvents.isEmpty {
            HStack(spacing: 12) {
                Image(systemName: "calendar.badge.clock")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Text(isTodaySelected ? "No upcoming events" : "No events on this day")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    addMode = .appointment
                    controlState.showingAddEventSheet = true
                } label: {
                    Text("Add")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.CustomColors.mutedRaspberry)
                }
                .buttonStyle(.borderless)
            }
            .padding(.vertical, 8)
            .listRowSeparator(.hidden)
        } else {
            ForEach(displayedEvents, id: \.calendarItemIdentifier) { event in
                TriTrackEventRow(event: event, selectedDate: $selectedDate)
                    .listRowSeparator(.hidden)
                    .onTapGesture {
                        selectedEvent = EKCalendarItemWrapper(item: event)
                    }
                    .accessibilityAction(.default) {
                        selectedEvent = EKCalendarItemWrapper(item: event)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            eventToDelete = event
                            showDeleteEventConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            selectedEvent = EKCalendarItemWrapper(item: event)
                        } label: {
                            Label("Details", systemImage: "eye")
                        }
                        .tint(.blue)
                    }
                    .contextMenu {
                        Button {
                            selectedEvent = EKCalendarItemWrapper(item: event)
                        } label: {
                            Label("View Details", systemImage: "eye")
                        }

                        Button {
                            openInCalendarApp(event: event)
                        } label: {
                            Label("Open in Calendar", systemImage: "calendar")
                        }

                        Divider()

                        Button(role: .destructive) {
                            eventToDelete = event
                            showDeleteEventConfirmation = true
                        } label: {
                            Label("Delete Event", systemImage: "trash")
                        }
                    }
            }
        }
    }

    @ViewBuilder
    private var reminderList: some View {
        if displayedReminders.isEmpty {
            HStack(spacing: 12) {
                Image(systemName: "bell.badge")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Text(isTodaySelected ? "No upcoming reminders" : "No reminders on this day")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    addMode = .reminder
                    controlState.showingAddEventSheet = true
                } label: {
                    Text("Add")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.CustomColors.mutedRaspberry)
                }
                .buttonStyle(.borderless)
            }
            .padding(.vertical, 8)
            .listRowSeparator(.hidden)
        } else {
            ForEach(displayedReminders, id: \.calendarItemIdentifier) { reminder in
                TriTrackReminderRow(reminder: reminder, selectedDate: $selectedDate) {
                    toggleReminder(reminder, for: selectedDate)
                } onTap: {
                    selectedReminder = EKCalendarItemWrapper(item: reminder)
                }
                .listRowSeparator(.hidden, edges: .all)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        reminderToDelete = reminder
                        showDeleteReminderConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        toggleReminder(reminder, for: selectedDate)
                    } label: {
                        Label(
                            reminder.isCompleted ? "Incomplete" : "Complete",
                            systemImage: reminder.isCompleted ? "circle" : "checkmark.circle"
                        )
                    }
                    .tint(reminder.isCompleted ? .orange : .green)
                }
                .contextMenu {
                    Button {
                        selectedReminder = EKCalendarItemWrapper(item: reminder)
                    } label: {
                        Label("View Details", systemImage: "eye")
                    }

                    Button {
                        openInRemindersApp()
                    } label: {
                        Label("Open in Reminders", systemImage: "checklist")
                    }

                    Divider()

                    Button {
                        toggleReminder(reminder, for: selectedDate)
                    } label: {
                        Label(
                            reminder.isCompleted ? "Mark as Incomplete" : "Mark as Completed",
                            systemImage: reminder.isCompleted ? "circle" : "checkmark.circle"
                        )
                    }

                    Button(role: .destructive) {
                        reminderToDelete = reminder
                        showDeleteReminderConfirmation = true
                    } label: {
                        Label("Delete Reminder", systemImage: "trash")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var undoToastView: some View {
        if showUndoToast, let backup = lastDeletedItem {
            HStack(spacing: 12) {
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.CustomColors.mutedRaspberry)

                Text("\(backup.itemTypeDescription) deleted")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)

                Spacer()

                Button {
                    performUndo()
                } label: {
                    Text("Undo")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.CustomColors.mutedRaspberry)
                }
                .buttonStyle(.plain)

                Button {
                    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                        showUndoToast = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                        .padding(4)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 90)
            .transition(unsafe reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
        }
    }

    private func refreshData() async {
        do {
            try eventKitHandler.fetchAppointments(selectedDate: selectedDate)
            try eventKitHandler.fetchAllEvents()
            try eventKitHandler.fetchReminders(startDate: selectedDate)
            try eventKitHandler.fetchAllReminders()
        } catch {
            controlState.error = error
        }
    }

    private func initialLoad() async {
        do {
            _ = try await eventKitHandler.requestAccess(for: .event)
            _ = try await eventKitHandler.requestAccess(for: .reminder)
            await refreshData()
        } catch {
            controlState.error = error
        }
    }

    private func openInCalendarApp(event: EKEvent) {
        let interval = (event.startDate ?? selectedDate).timeIntervalSinceReferenceDate
        if let url = URL(string: "calshow://\(interval)") {
            openURL(url)
        }
    }

    private func openInRemindersApp() {
        if let url = URL(string: "x-apple-reminderkit://") {
            openURL(url)
        }
    }

    private func upsertReminder(_ reminder: EKReminder) {
        if let index = eventKitHandler.reminders.firstIndex(
            where: { $0.calendarItemIdentifier == reminder.calendarItemIdentifier }
        ) {
            eventKitHandler.reminders[index] = reminder
        } else {
            eventKitHandler.reminders.append(reminder)
        }
    }

    private func toggleReminder(_ reminder: EKReminder, for date: Date?) {
        do {
            let updatedReminder = try eventKitHandler.markReminder(
                complete: !reminder.isCompleted,
                reminder: reminder,
                date: date ?? .init()
            )
            upsertReminder(updatedReminder)
            if let index = eventKitHandler.allReminders.firstIndex(where: { $0.calendarItemIdentifier == updatedReminder.calendarItemIdentifier }) {
                eventKitHandler.allReminders[index] = updatedReminder
            }
        } catch {
            controlState.error = error
        }
    }

    private func deleteReminder(_ reminder: EKReminder) {
        let priorityEnum: EKReminderPriority = switch reminder.priority {
            case 1...4: .high
            case 5: .medium
            case 6...9: .low
            default: EKReminderPriority.none
            }

        let backup = DeletedReminderBackup(
            title: reminder.title ?? "Reminder",
            notes: reminder.notes,
            dueDateComponents: reminder.dueDateComponents,
            recurrenceRules: reminder.recurrenceRules,
            alarms: reminder.alarms,
            priority: priorityEnum,
            isCompleted: reminder.isCompleted
        )

        do {
            try eventKitHandler.deleteReminder(reminder)
            eventKitHandler.reminders.removeAll {
                $0.calendarItemIdentifier == reminder.calendarItemIdentifier
            }
            eventKitHandler.allReminders.removeAll {
                $0.calendarItemIdentifier == reminder.calendarItemIdentifier
            }
            triggerUndoToast(with: .reminder(backup))
        } catch {
            controlState.error = error
        }
    }

    private func deleteEvent(_ event: EKEvent) {
        let backup = DeletedEventBackup(
            title: event.title ?? "Event",
            startDate: event.startDate,
            endDate: event.endDate,
            isAllDay: event.isAllDay,
            notes: event.notes,
            location: event.location,
            structuredLocation: event.structuredLocation,
            recurrenceRules: event.recurrenceRules,
            alarm: event.alarms?.first
        )

        do {
            try eventKitHandler.deleteEvent(event)
            eventKitHandler.events.removeAll {
                $0.calendarItemIdentifier == event.calendarItemIdentifier
            }
            eventKitHandler.allEvents.removeAll {
                $0.calendarItemIdentifier == event.calendarItemIdentifier
            }
            triggerUndoToast(with: .event(backup))
        } catch {
            controlState.error = error
        }
    }

    private func triggerUndoToast(with backup: DeletedItemBackup) {
        HapticsHandler.notification(.success)
        undoTimerTask?.cancel()
        lastDeletedItem = backup
        withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.8)) {
            showUndoToast = true
        }

        undoTimerTask = Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            if !Task.isCancelled {
                await MainActor.run {
                    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.25)) {
                        showUndoToast = false
                    }
                }
            }
        }
    }

    private func performUndo() {
        undoTimerTask?.cancel()
        guard let backup = lastDeletedItem else {
            return
        }

        switch backup {
        case let .event(eventBackup):
            restoreEvent(eventBackup)
        case let .reminder(reminderBackup):
            restoreReminder(reminderBackup)
        }

        HapticsHandler.notification(.success)
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.25)) {
            showUndoToast = false
            lastDeletedItem = nil
        }
    }

    private func restoreEvent(_ backup: DeletedEventBackup) {
        do {
            _ = try eventKitHandler.createEvent(
                title: backup.title,
                startDate: backup.startDate,
                endDate: backup.endDate,
                isAllDay: backup.isAllDay,
                notes: backup.notes,
                recurrenceRules: backup.recurrenceRules,
                location: backup.location,
                structuredLocation: backup.structuredLocation,
                alarm: backup.alarm
            )
            Task { await refreshData() }
        } catch {
            controlState.error = error
        }
    }

    private func restoreReminder(_ backup: DeletedReminderBackup) {
        do {
            try eventKitHandler.createReminder(
                title: backup.title,
                notes: backup.notes,
                dueDateComponents: backup.dueDateComponents ?? .init(),
                recurrenceRules: backup.recurrenceRules,
                alarms: backup.alarms,
                priority: backup.priority
            )
            Task { await refreshData() }
        } catch {
            controlState.error = error
        }
    }
}

struct DeletedEventBackup {
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let notes: String?
    let location: String?
    let structuredLocation: EKStructuredLocation?
    let recurrenceRules: [EKRecurrenceRule]?
    let alarm: EKAlarm?
}

struct DeletedReminderBackup {
    let title: String
    let notes: String?
    let dueDateComponents: DateComponents?
    let recurrenceRules: [EKRecurrenceRule]?
    let alarms: [EKAlarm]?
    let priority: EKReminderPriority
    let isCompleted: Bool
}

enum DeletedItemBackup {
    case event(DeletedEventBackup)
    case reminder(DeletedReminderBackup)

    // MARK: Internal

    var itemTypeDescription: String {
        switch self {
        case .event: "Event"
        case .reminder: "Reminder"
        }
    }
}
