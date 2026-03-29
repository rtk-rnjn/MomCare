import EventKit
import SwiftUI

struct TriTrackReminderRow: View {
    // MARK: Internal

    let reminder: EKReminder
    @Binding var selectedDate: Date

    let onToggle: () throws -> Void
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            dateCapsule
            reminderInfo(selectedDate: selectedDate)
            Spacer()
            completionIndicator
        }
        .onTapGesture { onTap() }
        .opacity(reminder.isCompleted ? 0.6 : 1)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(reminder.title ?? "Reminder")
        .accessibilityHint("Double tap to view reminder details")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(.default) { onTap() }
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
}

extension TriTrackReminderRow {
    var dueDate: Date? {
        reminder.dueDateComponents?.date
    }

    var hasRecurrence: Bool {
        !(reminder.recurrenceRules ?? []).isEmpty
    }

    var hasRecurrenceEnd: Bool {
        reminder.recurrenceRules?.contains { $0.recurrenceEnd != nil } ?? false
    }
}

extension TriTrackReminderRow {
    enum ReminderStatus {
        case past
        case pastRecurring
        case future
        case futureRecurring
        case futureRecurringWithEnd
        case today
    }

    func status(now: Date) -> ReminderStatus {
        guard let dueDate else {
            return .future
        }

        let calendar = Calendar.current

        if calendar.isDate(dueDate, inSameDayAs: Date()) {
            return .today
        }

        if dueDate < now {
            if hasRecurrence {
                return .pastRecurring
            }

            return .past
        }

        if hasRecurrence {
            if hasRecurrenceEnd {
                return .futureRecurringWithEnd
            }

            return .futureRecurring
        }

        return .future
    }
}

extension TriTrackReminderRow {
    func backgroundColor(now: Date) -> Color {
        switch status(now: now) {
        case .past:
            reduceTransparency ? Color(.systemGray5) : .red.opacity(0.15)

        case .pastRecurring:
            reduceTransparency ? Color(.systemGray5) : .orange.opacity(0.15)

        case .today:
            Color.CustomColors.mutedRaspberry

        case .future:
            Color(.systemGray6)

        case .futureRecurring:
            reduceTransparency ? Color(.systemGray5) : .blue.opacity(0.15)

        case .futureRecurringWithEnd:
            reduceTransparency ? Color(.systemGray5) : .purple.opacity(0.15)
        }
    }

    func foregroundColor(now: Date) -> Color {
        switch status(now: now) {
        case .past:
            .red

        case .pastRecurring:
            .orange

        case .today:
            .white

        case .future:
            .primary

        case .futureRecurring:
            .blue

        case .futureRecurringWithEnd:
            .purple
        }
    }
}

extension TriTrackReminderRow {
    var dateCapsule: some View {
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
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor(now: Date()))
        )
        .foregroundStyle(foregroundColor(now: Date()))
        .overlay(
            differentiateWithoutColor && dueDate ?? Date() < Date()
            ? Image(systemName: hasRecurrence ? "exclamationmark.2" : "exclamationmark")
                .font(.caption.bold())
                .foregroundStyle(.red)
            : nil
        )
    }
}

extension TriTrackReminderRow {
    func reminderInfo(selectedDate _: Date?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(reminder.title)
                .font(.headline)
                .lineLimit(1)
                .strikethrough(reminder.isCompleted)

            if let dueDate {
                HStack(spacing: 6) {
                    Text(dueDate.formatted(.dateTime.hour().minute()))
                        .font(.subheadline)

                    if hasRecurrence {
                        Image(systemName: "repeat")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if hasRecurrenceEnd {
                        Image(systemName: "stop.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .foregroundStyle(.secondary)
            }

            if let notes = reminder.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

extension TriTrackReminderRow {
    var completionIndicator: some View {
        Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
            .foregroundStyle(
                reminder.isCompleted
                ? .green
                : (dueDate ?? Date() < Date() ? .red : .gray.opacity(0.6))
            )
            .onTapGesture { toggleReminder() }
            .accessibilityLabel(reminder.isCompleted ? "Mark as incomplete" : "Mark as complete")
            .accessibilityHint("Toggles the completion status of this reminder")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction(.default) { toggleReminder() }
    }

    func toggleReminder() {
        if reduceMotion {
            try? onToggle()
        } else {
            withAnimation(reduceMotion ? nil : .easeInOut) {
                try? onToggle()
            }
        }
    }
}
