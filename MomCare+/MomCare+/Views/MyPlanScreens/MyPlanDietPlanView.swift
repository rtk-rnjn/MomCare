import SwiftUI
import TipKit

struct MyPlanDietPlanView: View {

    // MARK: Internal

    var body: some View {
        VStack(spacing: 12) {
            ProgressCardView(
                plan: contentServiceHandler.myPlanModel,

                calorieIntake: contentServiceHandler.nutritionIntakeTotals?.calories ?? 0,
                calorieGoal: contentServiceHandler.nutritionGoalTotals?.calories ?? 0,
                recommendedCalorieGoal: contentServiceHandler.recommendedNutritionGoalTotals?.calories ?? 0,

                proteinIntake: contentServiceHandler.nutritionIntakeTotals?.protein ?? 0,
                proteinGoal: contentServiceHandler.nutritionGoalTotals?.protein ?? 0,
                recommendedProteinGoal: contentServiceHandler.recommendedNutritionGoalTotals?.protein ?? 0,

                fatIntake: contentServiceHandler.nutritionIntakeTotals?.fats ?? 0,
                fatGoal: contentServiceHandler.nutritionGoalTotals?.fats ?? 0,
                recommendedFatGoal: contentServiceHandler.recommendedNutritionGoalTotals?.fats ?? 0,

                carbIntake: contentServiceHandler.nutritionIntakeTotals?.carbs ?? 0,
                carbGoal: contentServiceHandler.nutritionGoalTotals?.carbs ?? 0,
                recommendedCarbGoal: contentServiceHandler.recommendedNutritionGoalTotals?.carbs ?? 0,

                sugarIntake: contentServiceHandler.nutritionIntakeTotals?.sugar ?? 0,
                sugarGoal: contentServiceHandler.nutritionGoalTotals?.sugar ?? 0,
                recommendedSugarGoal: contentServiceHandler.recommendedNutritionGoalTotals?.sugar ?? 0,

                sodiumIntake: contentServiceHandler.nutritionIntakeTotals?.sodium ?? 0,
                sodiumGoal: contentServiceHandler.nutritionGoalTotals?.sodium ?? 0,
                recommendedSodiumGoal: contentServiceHandler.recommendedNutritionGoalTotals?.sodium ?? 0
            )
            .containerShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 16)
            .contextMenu {
                Button {
                    showGraph = true
                } label: {
                    Label("View in Graph", systemImage: "chart.bar.xaxis")
                }
            }

            TipView(dietContextMenuTip)
                .padding(.horizontal, 16)

            MealTimelineCardView(plan: contentServiceHandler.myPlanModel)
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
        .fullScreenCover(isPresented: $showGraph) {
            NutritionGraphRootView(
                calorieIntake: contentServiceHandler.nutritionIntakeTotals?.calories ?? 0,
                calorieGoal: contentServiceHandler.recommendedNutritionGoalTotals?.calories ?? 0,
                nutritionIntakeTotals: contentServiceHandler.nutritionIntakeTotals,
                nutritionGoalTotals: contentServiceHandler.recommendedNutritionGoalTotals
            )
        }
        .fullScreenCover(isPresented: $showWaterLog) {
            WaterLogView()
        }
        .fullScreenCover(isPresented: $showHistory) {
            if let mealPlan = contentServiceHandler.myPlanModel {
                DietPlanHistory(plan: mealPlan)
            }
        }
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
                .accessibilityLabel("More options")
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

    @State private var dietContextMenuTip: DietContextMenuTip = .init()

    @AppStorage(FeatureFlagState.experimentalFeatures.rawValue, store: UserDefaults(suiteName: "group.MomCare")) private var experimentalFeatures: Bool = false

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
}
