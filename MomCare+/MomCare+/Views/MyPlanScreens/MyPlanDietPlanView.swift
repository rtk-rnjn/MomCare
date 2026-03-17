import SwiftUI
import TipKit
import Charts
import HealthKit
import Combine

struct MyPlanDietPlanView: View {

    // MARK: Internal

    var body: some View {
        VStack(spacing: 12) {
            ProgressCardView(
                caloriesConsumed: contentServiceHandler.nurtitionConsumedTotals?.calories ?? 0,
                caloriesTarget: contentServiceHandler.nutritionTargetTotals?.calories ?? 0
            )
            .containerShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 16)
            .contextMenu {
                Button {
                    showGraph = true
                } label: {
                    Label("Show Pretty Graph", systemImage: "chart.bar.xaxis")
                }
            }
            .fullScreenCover(isPresented: $showGraph) {
                NutritionGraphRootView()
                    .environmentObject(contentServiceHandler)
            }

            MealTimelineCardView()
                .refreshable {
                    HapticsHandler.impact(.medium)
                    try? await contentServiceHandler.fetchMealPlan()
                }

                .padding(.bottom, 8)
                .frame(maxHeight: .infinity)
                .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
                .padding(.horizontal, 16)
        }
        .padding(.top, 8)
    }

    // MARK: Private

    @State private var showGraph = false

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
}
