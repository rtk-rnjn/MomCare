import EventKit
import SwiftUI
import TipKit

struct DashboardView: View {
    // MARK: Internal

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                weekAndEventSection
                progressSection
                dailyInsightsSection

                Color.clear.frame(height: 20)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 20)
        }
        .refreshable {
            HapticsHandler.impact(.medium)
            do {
                _ = try await authenticationService.refresh()
            } catch {}
        }
        .background(Color(.secondarySystemGroupedBackground))
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.large)
    }

    var weekAndEventSection: some View {
        HStack(spacing: 16) {
            DashboardWeekCardView(
                week: authenticationService.userModel?.pregnancyProgress.week,
                day: authenticationService.userModel?.pregnancyProgress.day,
                trimester: authenticationService.userModel?.pregnancyProgress.trimester,
                tip: tips.currentTip as? MomCareTips.Dashboard.DashboardWeekCardTip
            )
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    controlState.selectedTab = .triTrack
                    controlState.triTrackSegment = .meAndBaby
                }
                .accessibilityAction(.default) {
                    controlState.selectedTab = .triTrack
                    controlState.triTrackSegment = .meAndBaby
                }

            if let event = eventKitHandler.onGoingOrMostRecentUpcomingEvent {
                DashboardEventCardView(upcomingEvent: event, tip: tips.currentTip as? MomCareTips.Dashboard.DashboardEventCardTip)
                    .frame(maxWidth: .infinity)
                    .contextMenu {
                        Button {
                            selectedEvent = EKCalendarItemWrapper(item: event)
                        } label: {
                            Label("View Details", systemImage: "eye")
                        }
                    } preview: {
                        TriTrackEventDetailsContextView(event: event)
                    }
            } else {
                DashboardEventCardView(upcomingEvent: eventKitHandler.onGoingOrMostRecentUpcomingEvent, tip: tips.currentTip as? MomCareTips.Dashboard.DashboardEventCardTip)
                    .frame(maxWidth: .infinity)
            }
        }
        .sheet(item: $selectedEvent) {
            do {
                try eventKitHandler.fetchAllEvents()
            } catch {
                controlState.error = error
            }
        } content: { eventWrapper in
            if let event = eventWrapper.item as? EKEvent {
                EKEventView(event: event)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }

    var progressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progress")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.leading, 20)
                .accessibilityAddTraits(.isHeader)

            DashboardDietCardView(
                consumed: contentServiceHandler.nutritionIntakeTotals?.calories ?? 0,
                goal: contentServiceHandler.nutritionGoalTotals?.calories ?? 0,
                recommended: contentServiceHandler.recommendedNutritionGoalTotals?.calories ?? 0
            )
            .padding(.horizontal)
            .onTapGesture {
                controlState.selectedTab = .myPlan
                controlState.myPlanSegment = .diet
            }
            .accessibilityAddTraits(.isButton)
            .accessibilityHint("Double tap to view your diet plan")
            .accessibilityAction(.default) {
                controlState.selectedTab = .myPlan
                controlState.myPlanSegment = .diet
            }

            DashboardExerciseCard(
                stepsToday: Int(contentServiceHandler.stepsToday),
                caloriesBurnedToday: contentServiceHandler.caloriesBurned,
                exerciseDurationToday: contentServiceHandler.userExercises.totalVideoDurationCompletedSeconds,
                stepsGoalProgress: contentServiceHandler.stepsToday / contentServiceHandler.stepsGoal,
                caloriesGoalProgress: 0,
                exerciseGoalProgress: (contentServiceHandler.userExercises.totalVideoDurationCompletedSeconds / contentServiceHandler.totalExerciseDuration).clamped(to: 0...1)
            )
            .padding(.horizontal)
            .onTapGesture {
                controlState.selectedTab = .myPlan
                controlState.myPlanSegment = .exercise
            }
            .onAppear {
                contentServiceHandler.fetchTodaySteps()
            }
            .accessibilityAddTraits(.isButton)
            .accessibilityHint("Double tap to view your exercise plan")
            .accessibilityAction(.default) {
                controlState.selectedTab = .myPlan
                controlState.myPlanSegment = .exercise
            }
        }
    }

    var dailyInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Insights")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.leading, 20)
                .accessibilityAddTraits(.isHeader)

            HStack(spacing: 16) {
                DashboardInsightCardView(
                    title: "Today's Focus",
                    message: contentServiceHandler.todayFocusText,
                    icon: "target"
                )
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = contentServiceHandler.todayFocusText
                    } label: {
                        Label("Copy Today's Focus", systemImage: "doc.on.doc")
                    }

                    if experimentalFeatures {
                        // Hehehehe.
                        Button {
                            show2048Game = true
                        } label: {
                            Label("Play 2048", systemImage: "gamecontroller")
                        }
                    }
                }
                .fullScreenCover(isPresented: $show2048Game) {
                    Game2048View()
                }

                DashboardInsightCardView(
                    title: "Daily Tip",
                    message: contentServiceHandler.dailyTipText,
                    icon: "lightbulb"
                )
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = contentServiceHandler.dailyTipText
                    } label: {
                        Label("Copy Daily's Tip", systemImage: "doc.on.doc")
                    }

                    if experimentalFeatures {
                        // UwU
                        Button {
                            showWaterSortGame = true
                        } label: {
                            Label("Play Water Sort", systemImage: "gamecontroller")
                        }
                    }
                }
                .fullScreenCover(isPresented: $showWaterSortGame) {
                    GameWaterSortView()
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: Private

    @State private var tips = TipGroup {
        MomCareTips.Dashboard.DashboardWeekCardTip()
        MomCareTips.Dashboard.DashboardEventCardTip()
    }

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
    @EnvironmentObject private var eventKitHandler: EventKitHandler
    @EnvironmentObject private var authenticationService: MCAuthenticationService

    @EnvironmentObject private var controlState: ControlState

    @State private var selectedEvent: EKCalendarItemWrapper?

    @AppStorage(FeatureFlagState.experimentalFeatures.rawValue, store: Database.shared.userDefaults) private var experimentalFeatures: Bool = false

    @State private var show2048Game: Bool = false
    @State private var showWaterSortGame: Bool = false
}

extension View {
    func dashboardCardStyle() -> some View {
        clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }
}
