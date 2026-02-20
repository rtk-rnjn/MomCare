//
//  TriTrackCalendarItemContentView.swift
//  MomCare+
//
//  Created by Aryan singh on 15/02/26.
//

import EventKit
import MapKit
import SwiftUI

enum AddMode: String, CaseIterable {
    case appointment = "Appointment"
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

    var eventStore: EKEventStore = .init()

    var body: some View {
        VStack(spacing: 16) {
            if eventKitHandler.events.isEmpty {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 48))
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
            } else {
                LazyVStack {
                    ForEach(eventKitHandler.events, id: \.calendarItemIdentifier) { event in
                        AppointmentRow(event: event)
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
                    ForEach(eventKitHandler.reminders, id: \.calendarItemIdentifier) { reminder in
                        ReminderRow(reminder: reminder)
                            .contextMenu {
                                Button {
                                    selectedReminder = EKCalendarItemWrapper(item: reminder)
                                } label: {
                                    Label("View Details", systemImage: "eye")
                                }
                            } preview: {
                                TriTrackReminderDetailsContextView(reminder: reminder)
                            }
                            .onTapGesture {
                                selectedReminder = EKCalendarItemWrapper(item: reminder)
                            }
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: eventKitHandler.events)
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .sheet(
            isPresented: $controlState.showingAddEventSheet,
            onDismiss: {
                try? eventKitHandler.fetchAppointments(selectedDate: selectedDate)
                try? eventKitHandler.fetchReminders(startDate: selectedDate)
            }, content: {
                TriTrackAddCalendarItemSheetView()
                    .presentationDetents([.medium, .large])
                    .scrollDismissesKeyboard(.immediately)
            }
        )
        .sheet(
            item: $selectedEvent,
            onDismiss: {
                try? eventKitHandler.fetchAppointments(selectedDate: selectedDate)
            },
            content: { eventWrapper in
                if let event = eventWrapper.item as? EKEvent {
                    EventKitEventView(event: event)
                }
            }
        )
        .sheet(
            item: $selectedReminder,
            onDismiss: {
                try? eventKitHandler.fetchReminders(startDate: selectedDate)
            },
            content: { eventWrapper in
                if let reminder = eventWrapper.item as? EKReminder {
                    EKReminderView(reminder: reminder)
                }
            }
        )
        .task {
            _ = try? await eventStore.requestFullAccessToEvents()
            _ = try? await eventStore.requestFullAccessToReminders()
        }
        .onAppear {
            try? eventKitHandler.fetchAppointments(selectedDate: selectedDate)
            try? eventKitHandler.fetchReminders(startDate: selectedDate)
        }
        .onChange(of: selectedDate) {
            try? eventKitHandler.fetchAppointments(selectedDate: selectedDate)
            try? eventKitHandler.fetchReminders(startDate: selectedDate)
        }
        .refreshable {
            try? eventKitHandler.fetchAppointments(selectedDate: selectedDate)
            try? eventKitHandler.fetchReminders(startDate: selectedDate)
        }
    }

    // MARK: Private

    @EnvironmentObject private var eventKitHandler: EventKitHandler
    @EnvironmentObject private var controlState: ControlState

    @State private var selectedEvent: EKCalendarItemWrapper?
    @State private var selectedReminder: EKCalendarItemWrapper?

}

struct AppointmentRow: View {

    // MARK: Internal

    let event: EKEvent

    var body: some View {
        HStack(spacing: 14) {
            // Date Capsule
            VStack(spacing: 4) {
                Text(event.startDate.formatted(.dateTime.day()))
                    .font(.headline.weight(.bold))

                Text(event.startDate.formatted(.dateTime.month(.abbreviated)))
                    .font(.caption)
            }
            .frame(width: 50, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isToday ? Color.CustomColors.mutedRaspberry :
                        Color(.systemGray6))
            )
            .foregroundColor(isToday ? .white : .primary)

            // Title + Time
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(event.startDate.formatted(.dateTime.hour().minute()))
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let location = event.location,
                   !location.isEmpty {
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray.opacity(0.6))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .opacity(isPast ? 0.6 : 1)
    }

    // MARK: Private

    private var isToday: Bool {
        Calendar.current.isDateInToday(event.startDate)
    }

    private var isPast: Bool {
        event.startDate < Date()
    }

}

struct ReminderRow: View {

    // MARK: Internal

    let reminder: EKReminder

    var body: some View {
        HStack(spacing: 14) {
            // Date Capsule
            VStack(spacing: 4) {
                if let dueDate {
                    Text(dueDate.formatted(.dateTime.day()))
                        .font(.headline.weight(.bold))

                    Text(dueDate.formatted(.dateTime.month(.abbreviated)))
                        .font(.caption)
                } else {
                    Image(systemName: "calendar")
                        .font(.headline)
                }
            }
            .frame(width: 50, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        isPast ? Color.red.opacity(0.15) :
                            isToday ? Color.CustomColors.mutedRaspberry :
                            Color(.systemGray6)
                    )
            )
            .foregroundColor(
                isPast ? .red :
                    isToday ? .white :
                    .primary
            )

            // Title + Time
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.headline)
                    .lineLimit(1)
                    .strikethrough(reminder.isCompleted)

                if let dueDate {
                    Text(dueDate.formatted(.dateTime.hour().minute()))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if let notes = reminder.notes,
                   !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Completion Indicator
            Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(
                    reminder.isCompleted
                        ? .green
                        : (isPast ? .red : .gray.opacity(0.6))
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .opacity(reminder.isCompleted ? 0.6 : 1)
    }

    // MARK: Private

    private var dueDate: Date? {
        reminder.dueDateComponents?.date
    }

    private var isToday: Bool {
        guard let dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }

    private var isPast: Bool {
        guard let dueDate else { return false }
        return dueDate < Date() && !reminder.isCompleted
    }

}

struct TriTrackEventDetailsContextView: View {

    // MARK: Lifecycle

    init(event: EKEvent?) {
        self.event = event
        startDate = event?.startDate ?? Date()
        endDate = event?.endDate ?? Date()
    }

    // MARK: Internal

    var event: EKEvent?

    var startDate: Date = .init()
    var endDate: Date = .init()

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // MARK: Title + Location

            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(MomCareAccent.primary)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 4) {
                    Text(event?.title ?? "No Title")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)

                    if let location = event?.location,
                       !location.isEmpty {
                        Text(location)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // MARK: Date + Time

            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "clock")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.orange)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 4) {
                    if Calendar.current.isDate(startDate, inSameDayAs: endDate) {
                        Text(startDate.formatted(
                            .dateTime.weekday(.wide).day().month(.wide).year()
                        ))
                        .fontWeight(.medium)

                        Text(
                            "\(startDate.formatted(.dateTime.hour().minute())) – \(endDate.formatted(.dateTime.hour().minute()))"
                        )
                        .foregroundColor(.secondary)

                    } else {
                        Text("From")
                            .fontWeight(.medium)

                        Text(
                            startDate.formatted(
                                .dateTime.weekday(.abbreviated).day().month().year().hour().minute()
                            )
                        )
                        .foregroundColor(.secondary)

                        Text("To")
                            .fontWeight(.medium)
                            .padding(.top, 6)

                        Text(
                            endDate.formatted(
                                .dateTime.weekday(.abbreviated).day().month().year().hour().minute()
                            )
                        )
                        .foregroundColor(.secondary)
                    }
                }
                .font(.subheadline)
            }

            // MARK: Notes

            if let notes = event?.notes,
               !notes.isEmpty {
                Divider()
                    .padding(.vertical, 4)

                Text(notes)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }
}

struct TriTrackReminderDetailsContextView: View {

    // MARK: Lifecycle

    init(reminder: EKReminder?) {
        self.reminder = reminder
        dueDate = reminder?.dueDateComponents?.date
    }

    // MARK: Internal

    var reminder: EKReminder?
    var dueDate: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // MARK: Title + Priority

            HStack(alignment: .top, spacing: 14) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "list.bullet.circle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(
                        isCompleted ? .green :
                            isOverdue ? .red :
                            MomCareAccent.primary
                    )
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 6) {
                    Text(reminder?.title ?? "No Title")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .strikethrough(isCompleted)

                    if let priority = reminder?.priority,
                       priority > 0 {
                        Text(priorityText(priority))
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(priorityColor(priority).opacity(0.15))
                            .foregroundColor(priorityColor(priority))
                            .clipShape(Capsule())
                    }
                }
            }

            // MARK: Due Date

            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "clock")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.orange)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 4) {
                    if let dueDate {
                        Text(
                            dueDate.formatted(
                                .dateTime.weekday(.wide).day().month(.wide).year()
                            )
                        )
                        .fontWeight(.medium)

                        Text(dueDate.formatted(.dateTime.hour().minute()))
                            .foregroundColor(.secondary)

                        // Relative preview
                        Text(dueDate.formatted(.relative(presentation: .named)))
                            .font(.caption)
                            .foregroundColor(isOverdue ? .red : .secondary)
                    } else {
                        Text("No due date")
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
                .font(.subheadline)
            }

            // MARK: Notes

            if let notes = reminder?.notes,
               !notes.isEmpty {
                Divider()
                    .padding(.vertical, 4)

                Text(notes)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }

    // MARK: Private

    private var isCompleted: Bool {
        reminder?.isCompleted ?? false
    }

    private var isOverdue: Bool {
        guard let dueDate else { return false }
        return dueDate < Date() && !isCompleted
    }

}

private extension TriTrackReminderDetailsContextView {
    func priorityText(_ value: Int) -> String {
        switch value {
        case 1: "High Priority"
        case 5: "Medium Priority"
        case 9: "Low Priority"
        default: "Priority"
        }
    }

    func priorityColor(_ value: Int) -> Color {
        switch value {
        case 1: .red
        case 5: .orange
        case 9: .blue
        default: .gray
        }
    }
}

struct EKReminderView: View {

    // MARK: Internal

    let reminder: EKReminder

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Title Section

                Section {
                    HStack(spacing: 14) {
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 24))
                            .foregroundColor(
                                isCompleted ? .green :
                                    isOverdue ? .red :
                                    .accentColor
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(reminder.title)
                                .font(.headline)
                                .strikethrough(isCompleted)

                            if isOverdue {
                                Text("Overdue")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                // MARK: Due Date

                Section("Due Date") {
                    if let dueDate {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(
                                dueDate.formatted(
                                    .dateTime.weekday(.wide)
                                        .day()
                                        .month(.wide)
                                        .year()
                                )
                            )

                            Text(dueDate.formatted(.dateTime.hour().minute()))
                                .foregroundColor(.secondary)

                            Text(dueDate.formatted(.relative(presentation: .named)))
                                .font(.caption)
                                .foregroundColor(isOverdue ? .red : .secondary)
                        }
                    } else {
                        Text("No due date")
                            .foregroundColor(.secondary)
                    }
                }

                // MARK: Priority

                if reminder.priority > 0 {
                    Section("Priority") {
                        HStack {
                            Label(priorityText(reminder.priority), systemImage: "flag.fill")
                                .foregroundColor(priorityColor(reminder.priority))

                            Spacer()
                        }
                    }
                }

                // MARK: List

                Section("List") {
                    HStack {
                        Circle()
                            .fill(Color(reminder.calendar.cgColor))
                            .frame(width: 10, height: 10)

                        Text(reminder.calendar.title)
                            .foregroundColor(.secondary)
                    }
                }

                // MARK: Notes

                if let notes = reminder.notes,
                   !notes.isEmpty {
                    Section("Notes") {
                        Text(notes)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .interactiveDismissDisabled(false) // Allow swipe down
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss

    private var dueDate: Date? {
        reminder.dueDateComponents?.date
    }

    private var isCompleted: Bool {
        reminder.isCompleted
    }

    private var isOverdue: Bool {
        guard let dueDate else { return false }
        return dueDate < Date() && !isCompleted
    }

}

private extension EKReminderView {
    func priorityText(_ value: Int) -> String {
        switch value {
        case 1:
            "High"
        case 5:
            "Medium"
        case 9:
            "Low"
        default:
            "None"
        }
    }

    func priorityColor(_ value: Int) -> Color {
        switch value {
        case 1:
            .red
        case 5:
            .orange
        case 9:
            .blue
        default:
            .secondary
        }
    }
}
