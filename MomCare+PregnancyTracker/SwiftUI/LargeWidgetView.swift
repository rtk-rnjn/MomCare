//
//  LargeWidgetView.swift
//  MomCare
//
//  Created by Nupur on 13/09/25.
//

import SwiftUI
import WidgetKit

struct LargePregnancyWidgetView: View {
    let entry: TriTrackEntry

    @State private var pulse: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer(minLength: 20)
            // Week & Trimester Section
            HStack {
                VStack(alignment: .leading) {
                    Text("Week \(entry.week), Day \(entry.day)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#924350"))

                    Text("Trimester: \(entry.trimester)")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#924350").opacity(0.8))
                }

                Spacer()

                // Calories Burned Badge
                VStack(alignment: .trailing) {
                    Text("Calories Burned")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(Int(entry.caloriesBurned)) kcal")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "#C54B8C"))
                }
            }

            Spacer()

            Divider()
                .background(Color.gray.opacity(0.3))

            Spacer()

            // Diet Progress Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Today's Nutrition")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#924350"))

                HStack(spacing: 16) {
                    // Calories Ring
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 10)

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
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .scaleEffect(pulse ? 1.03 : 1.0)
                            .shadow(color: Color.pink.opacity(0.3), radius: pulse ? 8 : 3)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulse)

                        VStack {
                            Text("\(Int(entry.calories))")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "#924350"))

                            Text("of \(Int(entry.totalCalories)) kcal")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(width: 80, height: 80)

                    // Macronutrient Bars
                    VStack(alignment: .leading, spacing: 8) {
                        NutrientBar(name: "Protein", value: entry.protein, total: entry.totalProtein, color: Color(hex: "#6F4685"))
                        NutrientBar(name: "Carbs", value: entry.carbs, total: entry.totalCarbs, color: Color(hex: "#C54B8C"))
                        NutrientBar(name: "Fat", value: entry.fat, total: entry.totalFat, color: Color(hex: "#6C3082"))
                        Spacer() // ensures bars don't stick to top
                    }
                }
            }

            Spacer() // optional bottom padding
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .background(Color(hex: "#E9D3D3").opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .onAppear {
            pulse.toggle()
        }
    }
}

// MARK: - Nutrient Bar
struct NutrientBar: View {
    let name: String
    let value: Double
    let total: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                    .font(.caption)
                    .foregroundColor(Color(hex: "#924350"))
                Spacer()
                Text("\(Int(value))/\(Int(total))g")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: min(CGFloat(value / max(total, 1)) * geo.size.width, geo.size.width))
                }
            }
            .frame(height: 6)
        }
    }
}
