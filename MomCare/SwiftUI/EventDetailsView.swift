//
//  EventDetailsView.swift
//  MomCare
//
//  Created by RITIK RANJAN on 08/06/25.
//

import SwiftUI
import EventKit

struct EventDetailsView: View {
    let event: EKEvent
    let cellWidth: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title ?? "No Title")
                        .font(.headline)
                        .lineLimit(2)

                    if let location = event.location, !location.isEmpty {
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
                    if Calendar.current.isDate(event.startDate, inSameDayAs: event.endDate) {
                        Text(event.startDate.formatted(.dateTime.weekday(.wide).day().month(.wide).year()))
                        Text("from \(event.startDate.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute())) to \(event.endDate.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute()))")
                    } else {
                        Text("from \(event.startDate.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute().weekday(.abbreviated).day().month().year()))")
                        Text("to \(event.endDate.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute().weekday(.abbreviated).day().month().year()))")
                    }
                }
                .font(.subheadline)
            }

            if let notes = event.notes, !notes.isEmpty {
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
