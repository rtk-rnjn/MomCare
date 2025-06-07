//
//  FoodDetailsView.swift
//  MomCare
//
//  Created by RITIK RANJAN on 07/06/25.
//

import UIKit
import SwiftUI

struct FoodDetailsView: View {
    let food: FoodItem

    @State private var uiImage: UIImage? = nil

    var body: some View {
        HStack(spacing: 20) {
            VStack {
                Group {
                    if let image = uiImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "carrot.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.orange)
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .background(Color.secondary.opacity(0.1))
                .shadow(radius: 4)

                Text(food.name)
                    .font(.title2)
                    .fontWeight(.semibold)
            }

            VStack(spacing: 16) {
                NutrientView(symbol: "flame", label: "Cal", value: food.calories)
                NutrientView(symbol: "circle.hexagongrid", label: "Protein", value: food.protein)
            }

            VStack(spacing: 16) {
                NutrientView(symbol: "drop", label: "Fat", value: food.fat)
                NutrientView(symbol: "aqi.medium", label: "Salt", value: food.sodium)
            }

            VStack(spacing: 16) {
                NutrientView(symbol: "cube", label: "Sugar", value: food.sugar)
                NutrientView(symbol: "bolt", label: "Carbs", value: food.carbs)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
        .fixedSize(horizontal: true, vertical: true)
        .task {
            uiImage = await food.image
        }
    }

    struct NutrientView: View {
        let symbol: String
        let label: String
        let value: Double

        var body: some View {
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.headline)
                    .foregroundColor(.blue)
                Text("\(value, specifier: "%.0f")")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}
