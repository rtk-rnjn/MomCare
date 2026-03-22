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
            // TODO:
        }
        .background(Color(.secondarySystemGroupedBackground))
        .navigationTitle("ProgressHub")
        .navigationBarTitleDisplayMode(.large)
    }

    var weekAndEventSection: some View {
        HStack(spacing: 16) {
            DashboardWeekCardView(
                week: authenticationService.userModel?.pregnancyProgress.week,
                day: authenticationService.userModel?.pregnancyProgress.day,
                trimester: authenticationService.userModel?.pregnancyProgress.trimester
            )
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    controlState.selectedTab = .triTrack
                    controlState.triTrackSegment = .meAndBaby
                }

            if let event = eventKitHandler.onGoingOrMostRecentUpcomingEvent {
                DashboardEventCardView(upcomingEvent: event)
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
                DashboardEventCardView(upcomingEvent: eventKitHandler.onGoingOrMostRecentUpcomingEvent)
                    .frame(maxWidth: .infinity)
            }
        }
        .sheet(item: $selectedEvent) { eventWrapper in
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
                goal: contentServiceHandler.nutritionGoalTotals?.calories ?? 0
            )
            .padding(.horizontal)
            .onTapGesture {
                controlState.selectedTab = .myPlan
                controlState.myPlanSegment = .diet
            }
            .accessibilityAddTraits(.isButton)
            .accessibilityHint("Double tap to view your diet plan")

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
            .accessibilityAddTraits(.isButton)
            .accessibilityHint("Double tap to view your exercise plan")
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

                DashboardInsightCardView(
                    title: "Daily Tip",
                    message: contentServiceHandler.dailyTipText,
                    icon: "lightbulb"
                )
            }
            .padding(.horizontal)
        }
    }

    // MARK: Private

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
    @EnvironmentObject private var eventKitHandler: EventKitHandler
    @EnvironmentObject private var authenticationService: AuthenticationService

    @EnvironmentObject private var controlState: ControlState

    @State private var selectedEvent: EKCalendarItemWrapper?
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
