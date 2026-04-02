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
                eventList
            } header: {
                HStack {
                    Text("Events")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)

                    Spacer()

                    Text(eventKitHandler.events.count, format: .number)
                        .font(.headline)
                        .contentTransition(reduceMotion ? .identity : .numericText())
                        .animation(reduceMotion ? nil : .easeInOut, value: eventKitHandler.events.count)
                }
                .foregroundStyle(.black)
            }

            Section {
                reminderList
            } header: {
                HStack {
                    Text("Reminders")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)

                    Spacer()

                    Text(eventKitHandler.reminders.count, format: .number)
                        .font(.headline)
                        .contentTransition(reduceMotion ? .identity : .numericText())
                        .animation(reduceMotion ? nil : .easeInOut, value: eventKitHandler.reminders.count)
                }
                .foregroundStyle(.black)
            }
        }
        .listStyle(.plain)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
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
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @EnvironmentObject private var eventKitHandler: EventKitHandler
    @EnvironmentObject private var controlState: ControlState
    @Environment(\.openURL) private var openURL

    @State private var addMode: AddMode = .appointment

    @State private var selectedEvent: EKCalendarItemWrapper?
    @State private var selectedReminder: EKCalendarItemWrapper?

    private var eventList: some View {
        ForEach(eventKitHandler.events, id: \.calendarItemIdentifier) { event in
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
                }
        }
    }

    private var reminderList: some View {
        ForEach(eventKitHandler.reminders, id: \.calendarItemIdentifier) { reminder in
            TriTrackReminderRow(reminder: reminder, selectedDate: $selectedDate) {
                toggleReminder(reminder, for: .init())
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
            }
        }
    }

    private func refreshData() async {
        do {
            try eventKitHandler.fetchAppointments(selectedDate: selectedDate)
            try eventKitHandler.fetchReminders(startDate: selectedDate)

        } catch {
            controlState.error = error
        }
    }

    private func initialLoad() async {
        do {
            _ = try await eventKitHandler.requestAccess(for: .event)
            _ = try await eventKitHandler.requestAccess(for: .reminder)
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
        } catch {
            controlState.error = error
        }
    }

    private func deleteReminder(_ reminder: EKReminder) {
        do {
            try eventKitHandler.deleteReminder(reminder)
            eventKitHandler.reminders.removeAll {
                $0.calendarItemIdentifier == reminder.calendarItemIdentifier
            }
        } catch {
            controlState.error = error
        }
    }

    private func deleteEvent(_ event: EKEvent) {
        do {
            try eventKitHandler.deleteEvent(event)
            eventKitHandler.events.removeAll {
                $0.calendarItemIdentifier == event.calendarItemIdentifier
            }
        } catch {
            controlState.error = error
        }
    }
}
