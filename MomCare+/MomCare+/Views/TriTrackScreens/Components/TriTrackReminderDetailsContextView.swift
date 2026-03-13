import SwiftUI
import EventKit

struct TriTrackReminderDetailsContextView: View {

    // MARK: Internal

    let reminder: EKReminder

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // MARK: Title + Priority

            HStack(alignment: .top, spacing: 14) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "list.bullet.circle")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(isCompleted ? .green : isOverdue ? .red : MomCareAccent.primary)
                    .frame(width: 28)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 6) {
                    Text(reminder.title ?? "No Title")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .strikethrough(isCompleted)

                    if reminder.priority > 0 {
                        Text(priorityText(reminder.priority))
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(priorityColor(reminder.priority).opacity(0.15))
                            .foregroundColor(priorityColor(reminder.priority))
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
                    if let dueDate = reminder.dueDateComponents?.date {
                        Text(dueDate.formatted(.dateTime.weekday(.wide).day().month(.wide).year()))
                        .fontWeight(.medium)

                        Text(dueDate.formatted(.dateTime.hour().minute()))
                            .foregroundColor(.secondary)

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

            if let notes = reminder.notes,
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
        reminder.isCompleted
    }

    private var isOverdue: Bool {
        let dueDate = reminder.dueDateComponents?.date

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
