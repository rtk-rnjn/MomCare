import LNPopupUI
import SwiftUI
import Combine
import EventKit

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

    @Environment(\.scenePhase) private var scenePhase

    private let refreshTimer = Timer.publish(every: 300, on: .main, in: .common).autoconnect()

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
            _ = await authenticationService.autoLogin()
            try? await authenticationService.refresh()
        }
        .popup(isBarPresented: $controlState.showingPopupBar, isPopupOpen: $controlState.showingPopup) {
            MusicPlayerView()
        }
        .popupBarStyle(.floating)
        .popupInteractionStyle(.snap)
        .popupBarProgressViewStyle(.bottom)
        .popupCloseButtonStyle(.chevron)
        .onReceive(refreshTimer) { _ in
            Task {
                try? await authenticationService.refresh()
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
            await contentServiceHandler.requestAccess()

            await fetchDailyInsights()
            try? await contentServiceHandler.fetchMealPlan()
        }
        .task {
            _ = try? await eventKitHandler.eventStore.requestFullAccessToEvents()
            _ = try? await eventKitHandler.eventStore.requestFullAccessToReminders()
        }
        .onAppear {
            try? eventKitHandler.fetchAllEvents()
        }
        .task {
            if let networkResponse = try? await ContentService.shared.generateUserExercises(), let userExercises = networkResponse.data {
                contentServiceHandler.userExercises = userExercises

                await contentServiceHandler.fetchTotalUserExercisesDuration()
                await contentServiceHandler.fetchTotalUserExercisesCompletionDuration()
            }
        }
        .onChange(of: contentServiceHandler.userExercises) {
             Task {
                 await contentServiceHandler.fetchTotalUserExercisesDuration()
                 await contentServiceHandler.fetchTotalUserExercisesCompletionDuration()

                 await contentServiceHandler.updateWeeklyProgressForToday()
             }
        }
        .task {
            await contentServiceHandler.startStepCountObservation()
            await contentServiceHandler.fetchWeeklyProgress()
        }
    }

    private func fetchDailyInsights() async {
        guard let networkResponse = try? await ContentService.shared.generateDailyInsights() else {
            return
        }

        contentServiceHandler.todayFocusText = networkResponse.data?.todaysFocus ?? "Failed to fetch today's focus: \(networkResponse.errorMessage ?? "Unknown error") (\(networkResponse.statusCode))"
        contentServiceHandler.dailyTipText = networkResponse.data?.dailyTip ?? "Failed to fetch today's tip: \(networkResponse.errorMessage ?? "Unknown error") (\(networkResponse.statusCode))"
    }

}
