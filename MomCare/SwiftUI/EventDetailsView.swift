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
                        Label(location, systemImage: "mappin.and.ellipse")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 2) {
                    Text(event.startDate.formatted(date: .abbreviated, time: .shortened))
                    if event.endDate > event.startDate {
                        Text("to \(event.endDate.formatted(date: .abbreviated, time: .shortened))")
                            .foregroundColor(.secondary)
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
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
        .fixedSize(horizontal: false, vertical: true)
    }
}
