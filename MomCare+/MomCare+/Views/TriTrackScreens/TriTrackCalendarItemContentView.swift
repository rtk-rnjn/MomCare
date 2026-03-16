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

    var body: some View {
        List {
            Section {
                if isLoading {
                    loadingRow
                } else {
                    eventList
                }
            } header: {
                HStack {
                    Text("Events")
                        .font(.headline)

                    Spacer()

                    Text(eventKitHandler.events.count, format: .number)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .contentTransition(reduceMotion ? .identity : .numericText())
                        .animation(reduceMotion ? nil : .easeInOut, value: eventKitHandler.events.count)
                }
            }

            Section {
                if isLoading {
                    loadingRow
                } else {
                    reminderList
                }
            } header: {
                HStack {
                    Text("Reminders")
                        .font(.headline)

                    Spacer()

                    Text(eventKitHandler.reminders.count, format: .number)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .contentTransition(reduceMotion ? .identity : .numericText())
                        .animation(reduceMotion ? nil : .easeInOut, value: eventKitHandler.reminders.count)
                }
            }
        }
        .listStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .sheet(
            isPresented: $controlState.showingAddEventSheet,
            onDismiss: { Task { await refreshData() } }
        ) {
            TriTrackAddCalendarItemSheetView(selectedDate: $selectedDate, selectedSegment: addMode)
                .scrollDismissesKeyboard(.immediately)
        }
        .sheet(
            item: $selectedEvent,
            onDismiss: { Task { await refreshData() } }
        ) { itemWrapper in
            if let event = itemWrapper.item as? EKEvent {
                EKEventView(event: event)
            }
        }
        .sheet(
            item: $selectedReminder,
            onDismiss: { Task { await refreshData() } }
        ) { wrapper in
            if let reminder = wrapper.item as? EKReminder {
                EKReminderView(reminder: reminder, selectedDate: $selectedDate)
                    .interactiveDismissDisabled(true)
            }
        }
        .task {
            await initialLoad()
        }
        .onChange(of: selectedDate) {
            Task { await refreshData() }
        }
        .onAppear {
            Task { await refreshData() }
        }
        .refreshable {
            await refreshData()
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "An unexpected error occurred.")
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
    @State private var showErrorAlert = false
    @State private var alertMessage: String?
    @State private var isLoading = true

    private var loadingRow: some View {
        HStack {
            Spacer()
            ProgressView()
                .padding(.vertical, 8)
            Spacer()
        }
        .listRowBackground(Color.clear)
    }

    private var eventList: some View {
        ForEach(eventKitHandler.events, id: \.calendarItemIdentifier) { event in
            TriTrackEventRow(event: event, selectedDate: $selectedDate)
                .listRowSeparator(.hidden, edges: .all)
                .onTapGesture {
                    selectedEvent = EKCalendarItemWrapper(item: event)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        deleteEvent(event)
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
                        deleteEvent(event)
                    } label: {
                        Label("Delete Event", systemImage: "trash")
                    }
                } preview: {
                    TriTrackEventDetailsContextView(event: event)
                }
        }
    }

    // MARK: - Reminder List

    private var reminderList: some View {
        ForEach(eventKitHandler.reminders, id: \.calendarItemIdentifier) { reminder in
            TriTrackReminderRow(reminder: reminder, selectedDate: $selectedDate) {
                toggleReminder(reminder, for: selectedDate)
            } onTap: {
                selectedReminder = EKCalendarItemWrapper(item: reminder)
            }
            .listRowSeparator(.hidden, edges: .all)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    deleteReminder(reminder)
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
                    deleteReminder(reminder)
                } label: {
                    Label("Delete Reminder", systemImage: "trash")
                }
            } preview: {
                TriTrackReminderDetailsContextView(reminder: reminder)
            }
        }
    }

    private func refreshData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try eventKitHandler.fetchAppointments(selectedDate: selectedDate)
            try eventKitHandler.fetchReminders(startDate: selectedDate)
        } catch {
            alertMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    private func initialLoad() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let eventsGranted = try await eventKitHandler.eventStore.requestFullAccessToEvents()
            if !eventsGranted {
                alertMessage = "Event access denied. Please enable calendar permissions in Settings."
                showErrorAlert = true
            }

            let remindersGranted = try await eventKitHandler.eventStore.requestFullAccessToReminders()
            if !remindersGranted {
                alertMessage = "Reminder access denied. Please enable reminders permissions in Settings."
                showErrorAlert = true
            }
        } catch {
            alertMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    // MARK: - Deep Links

    /// Opens the native Calendar app scrolled to the event's date.
    /// Uses the `calshow://` URL scheme with an interval since reference date.
    private func openInCalendarApp(event: EKEvent) {
        let interval = (event.startDate ?? selectedDate).timeIntervalSinceReferenceDate
        if let url = URL(string: "calshow://\(interval)") {
            openURL(url)
        }
    }

    /// Opens the native Reminders app.
    /// `x-apple-reminderkit://` launches Reminders; deep-linking to a specific
    /// reminder is not supported by Apple's public URL scheme.
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

    private func toggleReminder(_ reminder: EKReminder, for date: Date) {
        do {
            let updatedReminder = try eventKitHandler.markReminder(
                complete: !reminder.isCompleted,
                reminder: reminder,
                date: date
            )
            upsertReminder(updatedReminder)
        } catch {
            alertMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    private func deleteReminder(_ reminder: EKReminder) {
        do {
            try eventKitHandler.deleteReminder(reminder)
            eventKitHandler.reminders.removeAll {
                $0.calendarItemIdentifier == reminder.calendarItemIdentifier
            }
        } catch {
            alertMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    private func deleteEvent(_ event: EKEvent) {
        do {
            try eventKitHandler.eventStore.remove(event, span: .thisEvent)
            eventKitHandler.events.removeAll {
                $0.calendarItemIdentifier == event.calendarItemIdentifier
            }
        } catch {
            alertMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
}
