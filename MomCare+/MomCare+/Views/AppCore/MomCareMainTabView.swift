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
    @EnvironmentObject private var musicKitHandler: MusicPlayerHandler
    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
    @EnvironmentObject private var eventKitHandler: EventKitHandler
    @EnvironmentObject private var controlState: ControlState

    @State private var isRefreshing = true
    @State private var requestingHealthKitAccess = true
    @State private var requestingEventKitAccess = true

    @Environment(\.scenePhase) private var scenePhase

    private let refreshTimer = Timer.publish(every: 600, on: .main, in: .common).autoconnect()

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
        .onReceive(refreshTimer) { _ in
            Task {
                await refreshAccessToken()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                Task {
                    try? await authenticationService.refresh()
                }
            }
        }
        .task {
            do {
                _ = try await contentServiceHandler.requestHealthKitAccess()
                await contentServiceHandler.startStepCountObservation()

                requestingHealthKitAccess = false
            } catch {
                controlState.error = error
            }
        }
        .task {
            do {
                _ = try await eventKitHandler.eventStore.requestFullAccessToEvents()
                _ = try await eventKitHandler.eventStore.requestFullAccessToReminders()
                
                requestingEventKitAccess = false
            } catch {
                controlState.error = error
            }
        }
        .onChange(of: requestingEventKitAccess) {
            do {
                try eventKitHandler.fetchAllEvents()
            } catch {
                controlState.error = error
            }
        }
        .onChange(of: isRefreshing) {
            Task {
                if let networkResponse = try? await ContentService.shared.generateUserExercises(), let userExercises = networkResponse.data {
                    contentServiceHandler.userExercises = userExercises

                    controlState.error = networkResponse.localizedError

                    await contentServiceHandler.fetchTotalUserExercisesDuration()
                    await contentServiceHandler.fetchTotalUserExercisesCompletionDuration()
                    await contentServiceHandler.fetchTotalUserExercisesCompleted()
                }
            }
        }
        .onChange(of: contentServiceHandler.userExercises) {
             Task {
                 await contentServiceHandler.fetchTotalUserExercisesDuration()
                 await contentServiceHandler.fetchTotalUserExercisesCompletionDuration()

                 await contentServiceHandler.updateWeeklyProgressForToday()
             }
        }
        .onChange(of: isRefreshing) {
            Task {
                await contentServiceHandler.fetchWeeklyProgress()

                await fetchDailyInsights()
                try? await contentServiceHandler.fetchMealPlan()
            }
        }
    }

    private func refreshAccessToken() async {
        do {
            try await authenticationService.refresh()
            isRefreshing = false
        } catch {
            controlState.error = RefreshError()
        }
    }

    private func fetchDailyInsights() async {
        guard let networkResponse = try? await ContentService.shared.generateDailyInsights() else {
            return
        }

        controlState.error = networkResponse.localizedError

        contentServiceHandler.todayFocusText = networkResponse.data?.todaysFocus ?? "Failed to fetch today's focus: \(networkResponse.errorMessage ?? "Unknown error") (\(networkResponse.statusCode))"
        contentServiceHandler.dailyTipText = networkResponse.data?.dailyTip ?? "Failed to fetch today's tip: \(networkResponse.errorMessage ?? "Unknown error") (\(networkResponse.statusCode))"
    }

}
