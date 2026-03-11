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
        VStack(spacing: 16) {
            if eventKitHandler.events.isEmpty && eventKitHandler.reminders.isEmpty {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: emptyStateIconSize))
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)

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
                .accessibilityLabel("Add event")
                .accessibilityHint("Opens a form to add a new event or appointment")
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
                        ReminderRow(reminder: reminder, onTap: {
                            let updatedReminder = try! eventKitHandler.markReminder(complete: !reminder.isCompleted, reminder: reminder)
                            try? eventKitHandler.fetchReminders(startDate: selectedDate)
                            return updatedReminder
                        })
                            .contextMenu {
                                Button {
                                    selectedReminder = EKCalendarItemWrapper(item: reminder)
                                } label: {
                                    Label("View Details", systemImage: "eye")
                                }

                                Button {
                                    _ = try? eventKitHandler.markReminder(complete: !reminder.isCompleted, reminder: reminder)
                                    try? eventKitHandler.fetchReminders(startDate: selectedDate)

                                } label: {
                                    if !reminder.isCompleted {
                                        Label("Mark as Completed", systemImage: "checkmark.circle")
                                    } else {
                                        Label("Mark as Incomplete", systemImage: "circle")
                                    }
                                }

                                Button {
                                    try? eventKitHandler.deleteReminder(reminder)
                                    try? eventKitHandler.fetchReminders(startDate: selectedDate)
                                } label: {
                                    Label("Delete Reminder", systemImage: "trash")
                                        .foregroundColor(.red)
                                }
                            } preview: {
                                TriTrackReminderDetailsContextView(reminder: reminder)
                            }
                            .onTapGesture {
                                selectedReminder = EKCalendarItemWrapper(item: reminder)
                            }
                    }
                }
                .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8), value: eventKitHandler.events.count + eventKitHandler.reminders.count)
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
                    .interactiveDismissDisabled(true)
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
                        .interactiveDismissDisabled(true)
                }
            }
        )
        .task {
            _ = try? await eventKitHandler.eventStore.requestFullAccessToEvents()
            _ = try? await eventKitHandler.eventStore.requestFullAccessToReminders()
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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric private var emptyStateIconSize: CGFloat = 48

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
            .accessibilityHidden(true)

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
                .accessibilityHidden(true)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .opacity(isPast ? 0.6 : 1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(event.title)
        .accessibilityValue(event.startDate.formatted(.dateTime.weekday().day().month().hour().minute()))
        .accessibilityHint("Double tap to view event details, long press for more options")
        .accessibilityAddTraits(.isButton)
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

    @State var reminder: EKReminder

    let onTap: (() -> EKReminder)?

    var body: some View {

        HStack(spacing: 14) {

            dateCapsule

            reminderInfo

            Spacer()

            completionIndicator
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .opacity(reminder.isCompleted ? 0.6 : 1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(reminder.title)
        .accessibilityValue(accessibilityValue)
        .accessibilityHint("Double tap to view reminder details, long press for more options")
        .accessibilityAddTraits(reminder.isCompleted ? [.isButton, .isSelected] : .isButton)
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    // MARK: Colors

    private var backgroundColor: Color {

        if isPast {
            return Color.red.opacity(0.15)
        } else if isToday {
            return Color.CustomColors.mutedRaspberry
        } else {
            return Color(.systemGray6)
        }
    }

    private var foregroundColor: Color {

        if isPast {
            return .red
        } else if isToday {
            return .white
        } else {
            return .primary
        }
    }

    // MARK: Accessibility Value

    private var accessibilityValue: String {

        if reminder.isCompleted {
            return "completed"
        }

        if isPast {
            return "overdue"
        }

        if let dueDate {
            return dueDate.formatted(.dateTime.weekday().day().month().hour().minute())
        }

        return "no due date"
    }

    // MARK: Dates

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

    // MARK: Date Capsule

    private var dateCapsule: some View {

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
                .fill(backgroundColor)
        )
        .foregroundColor(foregroundColor)
        .overlay(
            differentiateWithoutColor && isPast
            ? Image(systemName: "exclamationmark")
                .font(.caption.bold())
                .foregroundStyle(.red)
            : nil
        )
    }

    // MARK: Reminder Info

    private var reminderInfo: some View {

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

            if let notes = reminder.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
    }

    // MARK: Completion Button

    private var completionIndicator: some View {

        Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
            .foregroundColor(
                reminder.isCompleted
                ? .green
                : (isPast ? .red : .gray.opacity(0.6))
            )
            .onTapGesture {
                toggleReminder()
            }
            .accessibilityLabel(
                reminder.isCompleted
                ? "Mark as incomplete"
                : "Mark as completed"
            )
            .accessibilityHint(
                reminder.isCompleted
                ? "Double tap to mark as incomplete"
                : "Double tap to mark as completed"
            )
    }

    // MARK: Toggle

    private func toggleReminder() {

        let perform = {
            if let reminder = onTap?() {
                self.reminder = reminder
            }
        }

        if reduceMotion {
            perform()
        } else {
            withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.85)) {
                perform()
            }
        }
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
                    .font(.title3.weight(.semibold))
                    .foregroundColor(MomCareAccent.primary)
                    .frame(width: 28)
                    .accessibilityHidden(true)

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
                    .font(.body.weight(.medium))
                    .foregroundColor(.orange)
                    .frame(width: 28)
                    .accessibilityHidden(true)

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
                    .font(.title3.weight(.semibold))
                    .foregroundColor(
                        isCompleted ? .green :
                            isOverdue ? .red :
                            MomCareAccent.primary
                    )
                    .frame(width: 28)
                    .accessibilityHidden(true)

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
                    .font(.body.weight(.medium))
                    .foregroundColor(.orange)
                    .frame(width: 28)
                    .accessibilityHidden(true)

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
