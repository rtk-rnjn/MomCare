import LNPopupUI
import SwiftUI
import Combine
import EventKit
import HealthKit

final class RefreshError: LocalizedError {
    var errorDescription: String? {
        "Failed to refresh session. Please log in again."
    }

    var failureReason: String? {
        "The session could not be refreshed, likely due to an expired token or network issue."
    }

    var recoverySuggestion: String? {
        "Please try logging in again to refresh your session and regain access to all features."
    }
}

struct MomCareMainTabView: View {

    // MARK: Internal

    @Environment(\.horizontalSizeClass) var sizeClass

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
    @State private var requestingHealthKitAccess = true
    @State private var requestingEventKitAccess = true

    private let refreshTimer = Timer.publish(every: 900, on: .main, in: .common).autoconnect()

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
        .task { await refreshAccessToken() }
        .errorAlert(error: $controlState.error)
        .popup(isBarPresented: $controlState.showingPopupBar, isPopupOpen: $controlState.showingPopup) {
            MusicPlayerView()
        }
        .popupBarStyle(.floating)
        .popupInteractionStyle(.snap)
        .popupBarProgressViewStyle(.bottom)
        .popupCloseButtonStyle(.chevron)

        // Periodic refresh token to keep the session alive
        .onReceive(refreshTimer) { _ in
            Task {
                await refreshAccessToken()
            }
        }

        // HealthKitAccess
        .task {
            requestingHealthKitAccess = true
            defer { requestingEventKitAccess = false }

            do {
                _ = try await contentServiceHandler.requestHealthKitAccess()
                await contentServiceHandler.startStepCountObservation()

            } catch {
                controlState.error = error
            }
        }

        // EventKitAccess
        .task {
            requestingEventKitAccess = true
            defer { requestingEventKitAccess = false }

            do {
                let eventSuccess = try await eventKitHandler.eventStore.requestFullAccessToEvents()
                _ = try await eventKitHandler.eventStore.requestFullAccessToReminders()

                if eventSuccess {
                    try eventKitHandler.fetchAllEvents()
                }

            } catch {
                controlState.error = error
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
        DebugLogger.shared.log("Refreshing access token", level: .debug, category: .network)
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            try await authenticationService.refresh()
            DebugLogger.shared.log("Access token refreshed successfully", level: .debug, category: .network)
        } catch {
            DebugLogger.shared.log("Access token refresh failed: \(error.localizedDescription)", level: .error, category: .network)
            controlState.error = RefreshError()
        }
    }

    private func fetchDailyInsights() async throws {
        DebugLogger.shared.log("Fetching daily insights", level: .debug, category: .data)
        let networkResponse = try await ContentService.shared.generateDailyInsights()

        contentServiceHandler.todayFocusText = networkResponse.data?.todaysFocus ?? "Failed to fetch today's focus: \(networkResponse.errorMessage ?? "Unknown error") (\(networkResponse.statusCode))"
        contentServiceHandler.dailyTipText = networkResponse.data?.dailyTip ?? "Failed to fetch today's tip: \(networkResponse.errorMessage ?? "Unknown error") (\(networkResponse.statusCode))"
        DebugLogger.shared.log("Daily insights loaded: focus=\(contentServiceHandler.todayFocusText.prefix(40))", level: .debug, category: .data)
    }

}
