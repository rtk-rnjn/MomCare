import LNPopupUI
import SwiftUI
import Combine
import EventKit
import HealthKit

struct RefreshError: LocalizedError {
    var errorDescription: String? { "Failed to refresh session. Please log in again." }
    var failureReason: String? { "The session could not be refreshed, likely due to an expired token or network issue." }
    var recoverySuggestion: String? { "Please try logging in again to refresh your session and regain access to all features." }
}

struct HealthKitError: LocalizedError {
    var errorDescription: String? { "HealthKit Access Denied" }
    var failureReason: String? { "The app does not have permission to access HealthKit data." }
    var recoverySuggestion: String? { "Please grant HealthKit permissions in your device settings to enable health-related features." }
}

struct EventKitError: LocalizedError {
    var errorDescription: String? { "Calendar Access Denied" }
    var failureReason: String? { "The app does not have permission to access Calendar data." }
    var recoverySuggestion: String? { "Please grant Calendar permissions in your device settings to enable calendar-related features." }
}

struct MomCareMainTabView: View {

    // MARK: Internal

    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.openURL) var openURL

    var body: some View {
        tabViewContent(bottomPadding: 0)
            .tint(MomCareAccent.primary)
    }

    // MARK: Private

    @EnvironmentObject private var authenticationService: AuthenticationService
    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
    @EnvironmentObject private var eventKitHandler: EventKitHandler
    @EnvironmentObject private var controlState: ControlState

    @State private var isRefreshing = true

    @State private var eventKitError: (any Error)?
    @State private var healthKitError: (any Error)?
    @State private var refreshError: (any Error)?

    @State private var showLoginSheet = false

    private func tabViewContent(bottomPadding: CGFloat) -> some View {
        TabView(selection: $controlState.selectedTab) {
            TabSection {
                Tab(AppTab.progressHub.title, systemImage: AppTab.progressHub.systemImage, value: AppTab.progressHub) {
                    NavigationStack { DashboardView() }
                        .safeAreaPadding(bottomPadding)
                        .tag(AppTab.progressHub)
                }

                Tab(AppTab.myPlan.title, systemImage: AppTab.myPlan.systemImage, value: AppTab.myPlan) {
                    NavigationStack { MyPlanView() }
                        .safeAreaPadding(bottomPadding)
                        .tag(AppTab.myPlan)
                }

                Tab(AppTab.triTrack.title, systemImage: AppTab.triTrack.systemImage, value: AppTab.triTrack) {
                    NavigationStack { TriTrackView() }
                        .safeAreaPadding(bottomPadding)
                        .tag(AppTab.triTrack)
                }

                Tab(AppTab.moodNest.title, systemImage: AppTab.moodNest.systemImage, value: AppTab.moodNest) {
                    MoodNestView()
                        .safeAreaPadding(bottomPadding)
                        .tag(AppTab.moodNest)
                }
            }

            Tab(AppTab.profile.title, systemImage: AppTab.profile.systemImage, value: AppTab.profile) {
                NavigationStack { ProfileView() }
                    .safeAreaPadding(bottomPadding)
                    .tag(AppTab.profile)
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .task {
            await refreshAccessToken()
        }
        .errorAlert(error: $controlState.error)
        .errorAlert(error: $eventKitError) { _ in
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }

            Button(role: .close) {
                eventKitError = nil
            }
        }
        .errorAlert(error: $healthKitError) { _ in
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }

            Button(role: .close) {
                healthKitError = nil
            }
        }
        .errorAlert(error: $refreshError) { _ in
            Button("Login") {
                showLoginSheet = true
            }

            Button("Logout", role: .destructive) {
                refreshError = nil
                Task {
                    await authenticationService.logout()
                }
            }
        }
        .popup(isBarPresented: $controlState.showingPopupBar, isPopupOpen: $controlState.showingPopup) {
            MusicPlayerView()
        }
        .popupBarStyle(.floating)
        .popupInteractionStyle(.snap)
        .popupBarProgressViewStyle(.bottom)
        .popupCloseButtonStyle(.chevron)

        .sheet(isPresented: $showLoginSheet, onDismiss: {
            Task { await refreshAccessToken() }
        }) {
            ReAuthenticationSheetView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled()
        }

        // HealthKitAccess
        .task {
            do {
                _ = try await contentServiceHandler.requestHealthKitAccess()
                await contentServiceHandler.startStepCountObservation()

            } catch {
                healthKitError = HealthKitError()
            }
        }

        // EventKitAccess
        .task {
            do {
                let eventSuccess = try await eventKitHandler.eventStore.requestFullAccessToEvents()
                _ = try await eventKitHandler.eventStore.requestFullAccessToReminders()

                if eventSuccess {
                    try eventKitHandler.fetchAllEvents()
                }

            } catch {
                eventKitError = EventKitError()
            }
        }
        .onChange(of: authenticationService.requiresRefresh) {
            if authenticationService.requiresRefresh {
                Task { await refreshAccessToken() }
            }
        }
        .onChange(of: isRefreshing) {
            if isRefreshing {
                return
            }

            Task {
                do {
                    try await contentServiceHandler.fetchUserExercises()
                    try await fetchDailyInsights()
                    try await contentServiceHandler.fetchMealPlan()

                } catch {
                    controlState.error = error
                }
            }
        }
    }

    private func refreshAccessToken() async {
        isRefreshing = true

        do {
            try await authenticationService.refresh()
            isRefreshing = false
        } catch {
            if let error = error as? URLError {
                controlState.error = error
            } else {
                refreshError = RefreshError()
            }
        }
    }

    private func fetchDailyInsights() async throws {

        let networkResponse = try await ContentRepository.shared.generateDailyInsights()

        contentServiceHandler.todayFocusText = networkResponse.data.todaysFocus
        contentServiceHandler.dailyTipText = networkResponse.data.dailyTip

    }

}
