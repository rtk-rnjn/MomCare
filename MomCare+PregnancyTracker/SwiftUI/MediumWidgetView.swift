//
//  MediumWidgetView.swift
//  MomCare
//
//  Created by Nupur on 13/09/25.
//

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

                if let reminder = entry.nextReminder, !reminder.isEmpty {
                    Text(reminder)
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
        .background(Color(.systemBackground))
    }
}
