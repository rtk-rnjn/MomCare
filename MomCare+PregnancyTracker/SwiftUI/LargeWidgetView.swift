//
//  LargeWidgetView.swift
//  MomCare
//
//  Created by Nupur on 13/09/25.
//

import SwiftUI

struct LargePregnancyWidgetView: View {
    let entry: TriTrackEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Week & Trimester Section
            HStack {
                VStack(alignment: .leading) {
                    Text("Week \(entry.week), Day \(entry.day)")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Trimester: \(entry.trimester)")
                        .font(.headline)
                        .foregroundColor(.secondary)
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
                        .foregroundColor(.green)
                }
            }

            Divider()

            // Diet Progress Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Today's Nutrition")
                    .font(.headline)

                // Circular Progress for Calories
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                        Circle()
                            .trim(from: 0, to: min(CGFloat(entry.calories) / CGFloat(entry.totalCalories), 1))
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        VStack {
                            Text("\(Int(entry.calories))")
                                .font(.headline)
                            Text("of \(Int(entry.totalCalories)) kcal")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(width: 80, height: 80)

                    // Macronutrient Bars
                    VStack(alignment: .leading, spacing: 6) {
                        NutrientBar(name: "Protein", value: entry.protein, total: entry.totalProtein, color: .purple)
                        NutrientBar(name: "Carbs", value: entry.carbs, total: entry.totalCarbs, color: .orange)
                        NutrientBar(name: "Fat", value: entry.fat, total: entry.totalFat, color: .pink)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemBackground))
    }
}

struct NutrientBar: View {
    let name: String
    let value: Double
    let total: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(name)
                    .font(.caption)
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
