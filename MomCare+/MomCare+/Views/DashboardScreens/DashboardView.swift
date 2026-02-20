

import EventKit
import SwiftUI

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
            _ = await authenticationService.autoLogin()
            await fetchDailyInsights()
            try? eventKitHandler.fetchAllEvents()
            try? await healthKitHandler.fetchMealPlan()

            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        .background(Color(.secondarySystemGroupedBackground))
        .navigationTitle("ProgressHub")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $controlState.showingProfileSheet) {
            ProfileTableViewWrapper(authenticationService: authenticationService)
                .ignoresSafeArea()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
        .background(
            NavBarProfileAccessory {
                controlState.showingProfileSheet = true
            }
        )
        .task {
            await healthKitHandler.requestAccess()
            _ = await authenticationService.autoLogin()

            await fetchDailyInsights()
            try? await healthKitHandler.fetchMealPlan()
        }
        .onAppear {
            try? eventKitHandler.fetchAllEvents()
            healthKitHandler.startStepCountObservation()
        }
    }

    var weekAndEventSection: some View {
        HStack(spacing: 16) {
            DashboardWeekCardView()
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    controlState.selectedTab = .triTrack
                    controlState.triTrackSegment = .meAndBaby
                }

            DashboardEventCardView(upcomingEvent: eventKitHandler.mostRecentEvent)
                .frame(maxWidth: .infinity)
                .contextMenu {
                    Button {
                        if let upcomingEvent = eventKitHandler.mostRecentEvent {
                            selectedEvent = EKCalendarItemWrapper(item: upcomingEvent)
                        }
                    } label: {
                        Label("View Details", systemImage: "eye")
                    }
                } preview: {
                    TriTrackEventDetailsContextView(event: eventKitHandler.mostRecentEvent)
                }
        }
        .sheet(item: $selectedEvent) { eventWrapper in
            if let event = eventWrapper.item as? EKEvent {
                EventKitEventView(event: event)
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

            DashboardDietCardView(
                consumed: healthKitHandler.nurtitionConsumedTotals?.calories ?? 0,
                goal: healthKitHandler.nutritionTargetTotals?.calories ?? 0
            )
            .padding(.horizontal)

            DashboardExerciseCard(
                minutes: healthKitHandler.minutes,
                calories: healthKitHandler.caloriesBurned
            )

            .padding(.horizontal)
        }
    }

    var dailyInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Insights")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.leading, 20)

            HStack(spacing: 16) {
                DashboardInsightCardView(
                    title: "Today's Focus",
                    message: healthKitHandler.todayFocusText,
                    icon: "target"
                )

                DashboardInsightCardView(
                    title: "Daily Tip",
                    message: healthKitHandler.dailyTipText,
                    icon: "lightbulb"
                )
            }
            .padding(.horizontal)
        }
    }

    func fetchDailyInsights() async {
        guard let networkResponse = try? await ContentService.shared.fetchDailyInsights() else {
            return
        }

        healthKitHandler.todayFocusText = networkResponse.data?.todaysFocus ?? "Unable to fetch today's focus"
        healthKitHandler.dailyTipText = networkResponse.data?.dailyTip ?? "Unable to fetch today's tip"
    }

    // MARK: Private

    @EnvironmentObject private var healthKitHandler: HealthKitHandler
    @EnvironmentObject private var eventKitHandler: EventKitHandler

    @EnvironmentObject private var controlState: ControlState
    @EnvironmentObject private var authenticationService: AuthenticationService

    @Environment(\.dismiss) private var dismiss

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
