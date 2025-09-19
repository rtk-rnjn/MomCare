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

    @State private var pulse: Bool = false // Added for animation

    var body: some View {
        HStack(spacing: 16) {
            // Left Side: Week & Trimester
            VStack(alignment: .leading, spacing: 6) {
                Text("Week \(entry.week), Day \(entry.day)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundColor(Color(hex: "#924350"))

                Text("Trimester: \(entry.trimester)")
                    .font(.headline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundColor(Color(hex: "#924350"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Divider between text and ring
            Divider()
                .frame(height: 55) // match circle height
                .background(Color.gray.opacity(0.4))

            // Right Side: "Today's Nutrition" + Calories Ring
            VStack(spacing: 6) {
                Text("Today's Nutrition")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 6)

                    Circle()
                        .trim(from: 0, to: min(CGFloat(entry.calories) / CGFloat(entry.totalCalories), 1))
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#6F4685"),
                                    Color(hex: "#C54B8C"),
                                    Color(hex: "#6C3082")
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .scaleEffect(pulse ? 1.03 : 1.0)
                        .shadow(color: Color.pink.opacity(0.3), radius: pulse ? 8 : 3)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulse)

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
            .frame(maxWidth: 80)
        }
        .padding(.horizontal, 21)
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(.ultraThinMaterial)
        .background(Color(hex: "#E9D3D3").opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .onAppear {
            pulse.toggle()
        }
    }
}
