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
        Group {
            if eventKitHandler.events.isEmpty && eventKitHandler.reminders.isEmpty {
                emptyState
            } else {
                VStack(alignment: .leading, spacing: 24) {
                    if !eventKitHandler.events.isEmpty {
                        sectionHeader(title: "Events")
                        
                        eventList
                    }
                    
                    if !eventKitHandler.reminders.isEmpty {
                        sectionHeader(title: "Reminders")
                        
                        reminderList
                    }
                }
                .padding(.vertical)
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .sheet(
            isPresented: $controlState.showingAddEventSheet,
            onDismiss: refreshData
        ) {
            TriTrackAddCalendarItemSheetView(selectedDate: $selectedDate)
                .scrollDismissesKeyboard(.immediately)
        }
        .sheet(
            item: $selectedEvent,
            onDismiss: { try? eventKitHandler.fetchAppointments(selectedDate: selectedDate) }
        ) { wrapper in
            if let event = wrapper.item as? EKEvent {
                EventKitEventView(event: event)
            }
        }
        .sheet(
            item: $selectedReminder,
            onDismiss: { try? eventKitHandler.fetchReminders(startDate: selectedDate) }
        ) { wrapper in
            if let reminder = wrapper.item as? EKReminder {
                EKReminderView(reminder: reminder, selectedDate: $selectedDate)
                    .interactiveDismissDisabled(true)
            }
        }
        .task {
            try? await requestEventAccess()
            try? await requestReminderAccess()
        }
        .onAppear(perform: refreshData)
        .onChange(of: selectedDate, refreshData)
        .refreshable {
            refreshData()
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "An unexpected error occurred.")
        }
    }
    
    @ViewBuilder
    func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()
        }
        .padding(.horizontal)
    }

    // MARK: Private

    @EnvironmentObject private var eventKitHandler: EventKitHandler
    @EnvironmentObject private var controlState: ControlState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric private var emptyStateIconSize: CGFloat = 48

    @State private var selectedEvent: EKCalendarItemWrapper?
    @State private var selectedReminder: EKCalendarItemWrapper?
    @State private var showErrorAlert = false
    @State private var alertMessage: String?

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: emptyStateIconSize))
                .foregroundColor(.secondary)

            Text("No Events Scheduled")
                .font(.headline)

            Text("Add important appointments, check-ups, or milestones to track your pregnancy journey.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button {
                controlState.showingAddEventSheet = true
            } label: {
                Label("Add Event", systemImage: "plus")
                    .font(.body.weight(.semibold))
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.CustomColors.mutedRaspberry)
        }
    }

    private var eventList: some View {
        LazyVStack {
            ForEach(eventKitHandler.events, id: \.calendarItemIdentifier) { event in
                TriTrackEventRow(event: event, selectedDate: $selectedDate)
                    .contextMenu {
                        Button {
                            selectedEvent = EKCalendarItemWrapper(item: event)
                        } label: {
                            Label("View Details", systemImage: "eye")
                        }
                    } preview: {
                        TriTrackEventDetailsContextView(event: event)
                    }
                    .onTapGesture {
                        selectedEvent = EKCalendarItemWrapper(item: event)
                    }
            }
        }
    }

    private var reminderList: some View {
        LazyVStack {
            ForEach(eventKitHandler.reminders, id: \.calendarItemIdentifier) { reminder in
                TriTrackReminderRow(reminder: reminder, selectedDate: $selectedDate) {
                    toggleReminder(reminder, for: selectedDate)
                } onTap: {
                    selectedReminder = EKCalendarItemWrapper(item: reminder)
                }
                .contextMenu {
                    Button {
                        selectedReminder = EKCalendarItemWrapper(item: reminder)
                    } label: {
                        Label("View Details", systemImage: "eye")
                    }

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
    }

    private func requestEventAccess() async throws {
        let success = try await eventKitHandler.eventStore.requestFullAccessToEvents()
        if success {
            return
        }
        alertMessage = "Event access denied. Please enable calendar permissions in Settings to add and view events."
        showErrorAlert = true
    }

    private func requestReminderAccess() async throws {
        let success = try await eventKitHandler.eventStore.requestFullAccessToReminders()
        if success {
            return
        }
        alertMessage = "Reminder access denied. Please enable reminders permissions in Settings to add and view reminders."
        showErrorAlert = true
    }

    private func refreshData() {
        do {
            try eventKitHandler.fetchAppointments(selectedDate: selectedDate)
            try eventKitHandler.fetchReminders(startDate: selectedDate)
        } catch {
            alertMessage = error.localizedDescription
            showErrorAlert = true
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
}
