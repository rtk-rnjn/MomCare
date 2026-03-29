import EventKit
import SwiftUI

struct TriTrackEventDetailsContextView: View {
    let event: EKEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "calendar")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(MomCareAccent.primary)
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
                            .foregroundStyle(.secondary)
                    }
                }
            }

            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "clock")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.orange)
                    .frame(width: 28)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    if Calendar.current.isDate(event.startDate, inSameDayAs: event.endDate) {
                        Text(event.startDate.formatted(.dateTime.weekday(.wide).day().month(.wide).year()))
                        .fontWeight(.medium)

                        Text(
                            "\(event.startDate.formatted(.dateTime.hour().minute())) – \(event.endDate.formatted(.dateTime.hour().minute()))"
                        )
                        .foregroundStyle(.secondary)

                    } else {
                        Text("From")
                            .fontWeight(.medium)

                        Text(
                            event.startDate.formatted(
                                .dateTime.weekday(.abbreviated).day().month().year().hour().minute()
                            )
                        )
                        .foregroundStyle(.secondary)

                        Text("To")
                            .fontWeight(.medium)
                            .padding(.top, 6)

                        Text(
                            event.endDate.formatted(
                                .dateTime.weekday(.abbreviated).day().month().year().hour().minute()
                            )
                        )
                        .foregroundStyle(.secondary)
                    }
                }
                .font(.subheadline)
            }

            if let notes = event.notes,
               !notes.isEmpty {
                Divider()
                    .padding(.vertical, 4)

                Text(notes)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }
}
