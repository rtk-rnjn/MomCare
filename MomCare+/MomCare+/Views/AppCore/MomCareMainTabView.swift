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

    @State private var refreshError: (any Error)?

    @State private var showLoginSheet = false

    @State private var fetchingDataFromServer = true

    private func tabViewContent(bottomPadding: CGFloat) -> some View {
        TabView(selection: $controlState.selectedTab) {
            TabSection {
                Tab(AppTab.progress.title, systemImage: AppTab.progress.systemImage, value: AppTab.progress) {
                    NavigationStack { DashboardView() }
                        .safeAreaPadding(bottomPadding)
                        .tag(AppTab.progress)
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

                Tab(AppTab.mood.title, systemImage: AppTab.mood.systemImage, value: AppTab.mood) {
                    MoodNestView()
                        .safeAreaPadding(bottomPadding)
                        .tag(AppTab.mood)
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
        .permissionsOnboardingSheet(fetchingData: $fetchingDataFromServer)
        .errorAlert(error: $controlState.error)
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
        .popupInteractionStyle(.drag)
        .popupBarProgressViewStyle(.bottom)
        .popupCloseButtonStyle(.chevron)

        .sheet(isPresented: $showLoginSheet) {
            Task { await refreshAccessToken() }
        } content: {
            ReAuthenticationSheetView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled()
        }

        .onChange(of: isRefreshing) {
            if isRefreshing {
                return
            }

            Task {
                do {
                    fetchingDataFromServer = true
                    try await contentServiceHandler.fetchUserExercises()
                    try await fetchDailyInsights()
                    try await contentServiceHandler.fetchMealPlan()
                    fetchingDataFromServer = false

                } catch {
                    controlState.error = error
                    fetchingDataFromServer = false
                }
            }
        }

        .onChange(of: authenticationService.requiresRefresh) {
            if authenticationService.requiresRefresh {
                Task { await refreshAccessToken() }
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
