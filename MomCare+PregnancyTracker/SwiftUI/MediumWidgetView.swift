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
        HStack(spacing: 16) {
            // Left Side: Week & Trimester
            VStack(alignment: .leading, spacing: 6) {
                Text("Week \(entry.week), Day \(entry.day)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text("Trimester: \(entry.trimester)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Divider between text and ring
            Divider()
                .frame(height: 50) // keeps divider centered with the ring

            // Right Side: Calories Ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 6)

                Circle()
                    .trim(from: 0, to: min(CGFloat(entry.calories) / CGFloat(entry.totalCalories), 1))
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 1) {
                    Text("\(Int(entry.calories))")
                        .font(.subheadline)
                        .fontWeight(.bold)

                    Text("/\(Int(entry.totalCalories))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 55, height: 55)
        }
        .padding(.horizontal, 26)  // extra left/right space
        .padding(.vertical, 20)    // top/bottom padding
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color(.systemBackground))
    }
}
