import SwiftUI
import EventKit

struct TriTrackEventDetailsContextView: View {
    let event: EKEvent

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
                    Text(event.title ?? "No Title")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)

                    if let location = event.location,
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
                    if Calendar.current.isDate(event.startDate, inSameDayAs: event.endDate) {
                        Text(event.startDate.formatted(.dateTime.weekday(.wide).day().month(.wide).year()))
                        .fontWeight(.medium)

                        Text(
                            "\(event.startDate.formatted(.dateTime.hour().minute())) – \(event.endDate.formatted(.dateTime.hour().minute()))"
                        )
                        .foregroundColor(.secondary)

                    } else {
                        Text("From")
                            .fontWeight(.medium)

                        Text(
                            event.startDate.formatted(
                                .dateTime.weekday(.abbreviated).day().month().year().hour().minute()
                            )
                        )
                        .foregroundColor(.secondary)

                        Text("To")
                            .fontWeight(.medium)
                            .padding(.top, 6)

                        Text(
                            event.endDate.formatted(
                                .dateTime.weekday(.abbreviated).day().month().year().hour().minute()
                            )
                        )
                        .foregroundColor(.secondary)
                    }
                }
                .font(.subheadline)
            }

            // MARK: Notes

            if let notes = event.notes,
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

