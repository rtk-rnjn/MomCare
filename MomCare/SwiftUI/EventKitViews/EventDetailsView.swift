//
//  EventDetailsView.swift
//  MomCare
//
//  Created by RITIK RANJAN on 08/06/25.
//

import SwiftUI

struct EventDetailsView: View {

    // MARK: Lifecycle

    init(event: EventInfo?, cellWidth: CGFloat) {
        self.event = event
        self.cellWidth = cellWidth
        startDate = event?.startDate ?? Date()
        endDate = event?.endDate ?? Date()
    }

    // MARK: Internal

    var event: EventInfo?
    let cellWidth: CGFloat

    var startDate: Date = .init()
    var endDate: Date = .init()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text(event?.title ?? "No Title")
                        .font(.headline)
                        .lineLimit(2)

                    if let location = event?.location, !location.isEmpty {
                        Text(location)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }

            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 2) {
                    if Calendar.current.isDate(startDate, inSameDayAs: endDate) {
                        Text(startDate.formatted(.dateTime.weekday(.wide).day().month(.wide).year()))
                        Text("from \(startDate.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute())) to \(endDate.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute()))")
                    } else {
                        Text("from \(startDate.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute().weekday(.abbreviated).day().month().year()))")
                        Text("to \(endDate.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute().weekday(.abbreviated).day().month().year()))")
                    }
                }
                .font(.subheadline)
            }

            if let notes = event?.notes, !notes.isEmpty {
                Divider()
                Text(notes)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .lineLimit(3)
            }
        }
        .padding()
        .frame(width: cellWidth - 16, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }
}
