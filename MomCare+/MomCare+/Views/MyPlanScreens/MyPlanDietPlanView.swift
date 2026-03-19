import SwiftUI
import TipKit

struct MyPlanDietPlanView: View {

    // MARK: Internal

    var body: some View {
        VStack(spacing: 12) {
            ProgressCardView(
                caloriesConsumed: contentServiceHandler.nurtitionConsumedTotals?.calories ?? 0,
                caloriesTarget: contentServiceHandler.nutritionTargetTotals?.calories ?? 0,
                originalCaloriesTarget: contentServiceHandler.originalNutritionTargetTotals?.calories ?? 0
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
            .fullScreenCover(isPresented: $showWaterLog) {
                WaterLogView()
            }
            .fullScreenCover(isPresented: $showHistory) {
                if let mealPlan = contentServiceHandler.myPlanModel {
                    DietPlanHistory(plan: mealPlan)
                }
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
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Menu {
                    if experimentalFeatures {
                        Button {
                            showWaterLog = true
                        } label: {
                            Label("Water Intake Log", systemImage: "drop.fill")
                        }

                        Button {
                            showHistory = true
                        } label: {
                            Label("Meal Plan History", systemImage: "clock.arrow.circlepath")
                        }

                        Divider()
                    }

                    Button {
                        showHelp = true
                    } label: {
                        Label("Legend", systemImage: "questionmark.circle")
                    }

                } label: {
                    Image(systemName: "ellipsis")
                        .accessibilityHidden(true)
                }
            }
        }
        .sheet(isPresented: $showHelp) {
            NutritionProgressCardHelpView()
        }
    }

    // MARK: Private

    @State private var showGraph = false
    @State private var showWaterLog = false
    @State private var showHelp = false
    @State private var showHistory = false

    @AppStorage(FeatureFlagState.experimentalFeatures.rawValue, store: UserDefaults(suiteName: "group.MomCare")) private var experimentalFeatures: Bool = false

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
}
