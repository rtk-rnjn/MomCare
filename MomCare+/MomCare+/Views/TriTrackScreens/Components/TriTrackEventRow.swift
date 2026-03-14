import EventKit
import SwiftUI

struct TriTrackEventRow: View {

    let event: EKEvent

    @Binding var selectedDate: Date

    var body: some View {

        TimelineView(.periodic(from: .now, by: 60)) { context in

            HStack(spacing: 14) {

                dateCapsule

                appointmentInfo(now: context.date)

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
            .opacity(isPast(now: context.date) ? 0.6 : 1)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(event.title)
            .accessibilityValue(
                event.startDate.formatted(.dateTime.weekday().day().month().hour().minute())
            )
            .accessibilityHint("Double tap to view event details, long press for more options")
            .accessibilityAddTraits(.isButton)
        }
    }
}

extension TriTrackEventRow {

    var dateCapsule: some View {

        VStack(spacing: 4) {

            Text(event.startDate.formatted(.dateTime.day()))
                .font(.headline.weight(.bold))

            Text(event.startDate.formatted(.dateTime.month(.abbreviated)))
                .font(.caption)
        }
        .frame(width: 50, height: 50)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isToday ? Color.CustomColors.mutedRaspberry :
                        Color(.systemGray6))
        )
        .foregroundColor(isToday ? .white : .primary)
        .accessibilityHidden(true)
    }
}

extension TriTrackEventRow {

    func appointmentInfo(now: Date) -> some View {

        VStack(alignment: .leading, spacing: 4) {

            Text(event.title)
                .font(.headline)
                .lineLimit(1)

            HStack(spacing: 6) {
                if event.isAllDay {
                    Text("All-day")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text(event.startDate.formatted(.dateTime.hour().minute()))
                        .font(.subheadline)
                }

                HStack {
                    Text(event.startDate, style: .relative)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()

                    // Time (.) status

                    Text("•")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(isPast(now: now) ? .red : .green)

                    if isPast(now: now) {
                        Text("Ended")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.red)
                    } else if Calendar.current.isDate(event.startDate, inSameDayAs: now) {
                        Text("Today")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.green)
                    }
                }
            }

            if let location = event.location,
               !location.isEmpty {

                Text(location)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

extension TriTrackEventRow {

    private var isToday: Bool {
        Calendar.current.isDate(event.startDate, inSameDayAs: selectedDate)
    }

    private func isPast(now: Date) -> Bool {
        event.startDate < now
    }
}
