//
//  MyPlanDietPlanView.swift
//  MomCare+
//
//  Created by Aryan singh on 16/02/26.
//

import SwiftUI

struct MealSection: Identifiable {
    let id: UUID = .init()
    let title: String
    var items: [FoodReferenceModel]

    var isCompleted: Bool {
        items.allSatisfy(\.isConsumed)
    }
}

struct MyPlanDietPlanView: View {

    // MARK: Internal

    var body: some View {
        VStack(spacing: 12) {
            ProgressCardView(
                caloriesConsumed: healthKitHandler.nurtitionConsumedTotals?.calories ?? 0,
                caloriesTarget: healthKitHandler.nutritionTargetTotals?.calories ?? 0
            )
            .padding(.horizontal, 16)
            .containerShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    MealTimelineCardView()
                        .padding(.horizontal, 0)
                        .padding(.top, 8)
                        .padding(.bottom, 50)
                }
            }
            .frame(maxHeight: .infinity)
            .background(Color(.systemBackground))
            .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
            .padding(.horizontal, 16)
        }
        .padding(.top, 8)
    }

    // MARK: Private

    @EnvironmentObject private var healthKitHandler: HealthKitHandler

}
