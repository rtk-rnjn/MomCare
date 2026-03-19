import SwiftUI
import EventKit

struct TriTrackReminderRow: View {

    // MARK: Internal

    let reminder: EKReminder
    @Binding var selectedDate: Date

    let onToggle: () throws -> Void
    let onTap: () -> Void

    var body: some View {

        TimelineView(.periodic(from: .now, by: 1)) { context in

            HStack(spacing: 14) {
                dateCapsule
                reminderInfo(currentDate: context.date)
                Spacer()
                completionIndicator
            }
            .padding()
            .onTapGesture { onTap() }
            .opacity(reminder.isCompleted ? 0.6 : 1)
        }
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

        guard let dueDate else { return .future }

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
            return reduceTransparency ? Color(.systemGray5) : .red.opacity(0.15)

        case .pastRecurring:
            return reduceTransparency ? Color(.systemGray5) : .orange.opacity(0.15)

        case .today:
            return Color.CustomColors.mutedRaspberry

        case .future:
            return Color(.systemGray6)

        case .futureRecurring:
            return reduceTransparency ? Color(.systemGray5) : .blue.opacity(0.15)

        case .futureRecurringWithEnd:
            return reduceTransparency ? Color(.systemGray5) : .purple.opacity(0.15)
        }
    }

    func foregroundColor(now: Date) -> Color {

        switch status(now: now) {

        case .past:
            return .red

        case .pastRecurring:
            return .orange

        case .today:
            return .white

        case .future:
            return .primary

        case .futureRecurring:
            return .blue

        case .futureRecurringWithEnd:
            return .purple
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
        .foregroundColor(foregroundColor(now: Date()))
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

    func reminderInfo(currentDate: Date) -> some View {

        VStack(alignment: .leading, spacing: 4) {

            Text(reminder.title)
                .font(.headline)
                .lineLimit(1)
                .strikethrough(reminder.isCompleted)

            if let dueDate {

                HStack(spacing: 6) {

                    Text(dueDate.formatted(.dateTime.hour().minute()))
                        .font(.subheadline)

                    timerIndicator(dueDate: dueDate, now: currentDate)

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
}

extension TriTrackReminderRow {

    func timerIndicator(dueDate: Date, now: Date) -> some View {
        Text(dueDate, style: .relative)
            .font(.caption.weight(.medium))
            .lineLimit(1)
            .monospacedDigit()
            .contentTransition(reduceMotion ? .identity : .numericText(countsDown: true))
            .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.7), value: dueDate)
    }
}

extension TriTrackReminderRow {

    var completionIndicator: some View {

        Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
            .foregroundColor(
                reminder.isCompleted
                ? .green
                : (dueDate ?? Date() < Date() ? .red : .gray.opacity(0.6))
            )
            .onTapGesture { toggleReminder() }
            .accessibilityLabel(reminder.isCompleted ? "Mark as incomplete" : "Mark as complete")
            .accessibilityHint("Toggles the completion status of this reminder")
            .accessibilityAddTraits(.isButton)
    }

    func toggleReminder() {
        if reduceMotion {
            try? onToggle()
        } else {
            withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.85)) {
                try? onToggle()
            }
        }
    }
}
