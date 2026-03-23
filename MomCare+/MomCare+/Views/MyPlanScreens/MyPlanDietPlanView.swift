import SwiftUI
import TipKit

struct MyPlanDietPlanView: View {
    // MARK: Internal

    var body: some View {
        VStack(spacing: 12) {
            ProgressCardView(
                plan: contentServiceHandler.myPlanModel,

                calorieIntake: contentServiceHandler.nutritionIntakeTotals?.energy,
                calorieGoal: contentServiceHandler.nutritionGoalTotals?.energy,
                recommendedCalorieGoal: contentServiceHandler.recommendedNutritionGoalTotals?.energy,

                proteinIntake: contentServiceHandler.nutritionIntakeTotals?.proteinMass,
                proteinGoal: contentServiceHandler.nutritionGoalTotals?.proteinMass,
                recommendedProteinGoal: contentServiceHandler.recommendedNutritionGoalTotals?.proteinMass,

                fatIntake: contentServiceHandler.nutritionIntakeTotals?.fatsMass,
                fatGoal: contentServiceHandler.nutritionGoalTotals?.fatsMass,
                recommendedFatGoal: contentServiceHandler.recommendedNutritionGoalTotals?.fatsMass,

                carbIntake: contentServiceHandler.nutritionIntakeTotals?.carbsMass,
                carbGoal: contentServiceHandler.nutritionGoalTotals?.carbsMass,
                recommendedCarbGoal: contentServiceHandler.recommendedNutritionGoalTotals?.carbsMass,

                sugarIntake: contentServiceHandler.nutritionIntakeTotals?.sugarMass,
                sugarGoal: contentServiceHandler.nutritionGoalTotals?.sugarMass,
                recommendedSugarGoal: contentServiceHandler.recommendedNutritionGoalTotals?.sugarMass,

                sodiumIntake: contentServiceHandler.nutritionIntakeTotals?.sodiumMass,
                sodiumGoal: contentServiceHandler.nutritionGoalTotals?.sodiumMass,
                recommendedSodiumGoal: contentServiceHandler.recommendedNutritionGoalTotals?.sodiumMass
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

            MealTimelineCardView(plan: contentServiceHandler.myPlanModel)
                .refreshable {
                    HapticsHandler.impact(.medium)
                    do {
                        try await contentServiceHandler.fetchMealPlan()
                    } catch {
                        controlState.error = error
                    }
                }

                .padding(.bottom, 8)
                .frame(maxHeight: .infinity)
                .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
                .padding(.horizontal, 16)
        }
        .padding(.top, 8)
        .fullScreenCover(isPresented: $showGraph) {
            NutritionGraphRootView(
                calorieIntake: contentServiceHandler.nutritionIntakeTotals?.energy ?? .init(value: 0, unit: .kilocalories),
                calorieGoal: contentServiceHandler.recommendedNutritionGoalTotals?.energy ?? .init(value: 0, unit: .kilocalories),
                nutritionIntakeTotals: contentServiceHandler.nutritionIntakeTotals,
                nutritionGoalTotals: contentServiceHandler.recommendedNutritionGoalTotals
            )
        }
        .fullScreenCover(isPresented: $showWaterLog) {
            WaterLogView()
        }
        .fullScreenCover(isPresented: $showHistory) {
            DietPlanHistory()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showHistory = true
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if experimentalFeatures {
                        Button {
                            showWaterLog = true
                        } label: {
                            Label("Water Intake Log", systemImage: "drop.fill")
                        }

                        Divider()
                    }

                    Button {
                        showHelp = true
                    } label: {
                        Label("Guide", systemImage: "questionmark.circle")
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

    @AppStorage(FeatureFlagState.experimentalFeatures.rawValue, store: UserDefaults(suiteName: "group.MomCare")) private var experimentalFeatures: Bool = false

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
    @EnvironmentObject private var controlState: ControlState
}
