import SwiftUI
import WidgetKit

struct MediumPregnancyWidgetView: View {
    let entry: TriTrackEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Week \(entry.week), Day \(entry.day)")
                        .font(.title3)
                        .fontWeight(.bold)

                    Text("Trimester: \(entry.trimester)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                Text("Next Reminder")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let reminder = entry.nextReminder {
                    Text(reminder.title ?? "No title")
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(2)
                } else {
                    Text("No upcoming reminders")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
