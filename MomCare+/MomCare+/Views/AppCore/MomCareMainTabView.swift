import LNPopupUI
import SwiftUI
import Combine

struct MomCareMainTabView: View {

    // MARK: Internal

    var body: some View {
        tabViewContent(bottomPadding: 0)
            .tint(MomCareAccent.primary)
            .preferredColorScheme(.light)
    }

    func fetchDailyInsights() async {
        guard let networkResponse = try? await ContentService.shared.fetchDailyInsights() else {
            return
        }

        healthKitHandler.todayFocusText = networkResponse.data?.todaysFocus ?? "Failed to fetch today's focus: \(networkResponse.errorMessage ?? "Unknown error") (\(networkResponse.statusCode))"
        healthKitHandler.dailyTipText = networkResponse.data?.dailyTip ?? "Failed to fetch today's tip: \(networkResponse.errorMessage ?? "Unknown error") (\(networkResponse.statusCode))"
    }

    // MARK: Private

    @EnvironmentObject private var authenticationService: AuthenticationService
    @EnvironmentObject private var musicKitHandler: MusicPlayerHandler
    @EnvironmentObject private var healthKitHandler: HealthKitHandler
    @EnvironmentObject private var eventKitHandler: EventKitHandler
    @EnvironmentObject private var controlState: ControlState

    @Environment(\.scenePhase) private var scenePhase

    private let refreshTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private func tabViewContent(bottomPadding: CGFloat) -> some View {
        TabView(selection: $controlState.selectedTab) {
            NavigationStack { DashboardView() }
                .tabItem { Label(AppTab.progressHub.title, systemImage: AppTab.progressHub.systemImage) }
                .tag(AppTab.progressHub)
                .safeAreaPadding(bottomPadding)

            NavigationStack { MyPlanView() }
                .tabItem { Label(AppTab.myPlan.title, systemImage: AppTab.myPlan.systemImage) }
                .tag(AppTab.myPlan)
                .safeAreaPadding(bottomPadding)

            NavigationStack { TriTrackView() }
                .tabItem { Label(AppTab.triTrack.title, systemImage: AppTab.triTrack.systemImage) }
                .tag(AppTab.triTrack)
                .safeAreaPadding(bottomPadding)

            MoodNestView()
                .tabItem { Label(AppTab.moodNest.title, systemImage: AppTab.moodNest.systemImage) }
                .tag(AppTab.moodNest)
                .safeAreaPadding(bottomPadding)
        }
        .task {
            _ = await authenticationService.autoLogin()
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
            await healthKitHandler.requestAccess()

            await fetchDailyInsights()
            try? await healthKitHandler.fetchMealPlan()
        }
        .onAppear {
            try? eventKitHandler.fetchAllEvents()
            healthKitHandler.startStepCountObservation()
        }
    }

}
