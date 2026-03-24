import EventKit
import SwiftUI

struct TriTrackEventRow: View {
    // MARK: Internal

    let event: EKEvent

    @Binding var selectedDate: Date

    var body: some View {
        HStack(spacing: 14) {
            dateCapsule

            appointmentInfo()

            Spacer()
        }
        .opacity(isPast(now: selectedDate) ? 0.6 : 1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(event.title)
        .accessibilityValue(event.startDate.formatted(.dateTime.weekday().day().month().hour().minute()))
        .accessibilityHint("Double tap to view event details, long press for more options")
        .accessibilityAddTraits(.isButton)
    }

    // MARK: Private

    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    private var now: Date {
        .init()
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
        .overlay(
            isToday && differentiateWithoutColor
            ? RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary, lineWidth: 2)
            : nil
        )
        .accessibilityHidden(true)
    }
}

extension TriTrackEventRow {
    func appointmentInfo() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.title)
                .font(.headline)
                .lineLimit(1)

            HStack(spacing: 6) {
                if event.isAllDay {
                    Text("All-day")
                        .font(.subheadline)
                } else {
                    Text(event.startDate.formatted(.dateTime.hour().minute()))
                        .font(.subheadline)
                }

                HStack {
                    if differentiateWithoutColor {
                        Image(systemName: isPast(now: now) ? "xmark.circle" : "checkmark.circle")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(isPast(now: now) ? .red : .green)
                    } else {
                        Text("•")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(isPast(now: now) ? .red : .green)
                    }

                    if isPast(now: now) {
                        Text("Ended")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.red)
                    } else if Calendar.current.isDate(event.startDate, inSameDayAs: now) {
                        Text("Today")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.green)
                    } else if event.startDate > now {
                        Text("Upcoming")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.green)
                    } else {
                        Text("Past")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.red)
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

    private func isPast(now: Date? = .init()) -> Bool {
        event.startDate < now ?? self.now
    }
}
