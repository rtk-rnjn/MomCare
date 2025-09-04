//

//  ReminderDetailsView.swift

//  MomCare

//

//  Created by RITIK RANJAN on 08/06/25.

//

import SwiftUI

struct ReminderDetailsView: View {

    let reminder: ReminderInfo

    let cellWidth: CGFloat

    var body: some View {

        VStack(alignment: .leading, spacing: 12) {

            HStack(alignment: .top, spacing: 8) {

                if reminder.isCompleted {

                    Image(systemName: "checkmark.circle.fill")

                        .font(.title2)

                        .foregroundColor(.green)

                } else {

                    Image(systemName: "circle")

                        .font(.title2)

                        .foregroundColor(.gray)

                }

                VStack(alignment: .leading, spacing: 4) {

                    Text(reminder.title ?? "Reminder Title")

                        .font(.headline)

                        .lineLimit(2)

                }

            }

            if let dueDate = reminder.dueDateComponents?.date {

                HStack(spacing: 8) {

                    Image(systemName: "clock")

                        .foregroundColor(.orange)

                    VStack(alignment: .leading, spacing: 2) {

                        Text(dueDate.formatted(.dateTime.weekday(.wide).day().month(.wide).year()))

                        HStack(spacing: 4) {

                            Text(dueDate.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute()))

                            Text("(\(dueDate.relativeString(from: .init())))")

                        }

                    }

                    .font(.subheadline)

                }

            }

            if let notes = reminder.notes, !notes.isEmpty {

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
