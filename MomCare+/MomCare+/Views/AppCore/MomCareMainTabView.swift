import Combine
import EventKit
import HealthKit
import LNPopupUI
import SwiftUI

private let kFirstTime = "momcare_firsttime"

struct RefreshError: LocalizedError {
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

    var body: some View {
        tabViewContent(bottomPadding: 0)
            .tint(MomCareAccent.primary)
    }

    // MARK: Private

    @Environment(\.openURL) private var openURL
    @AppStorage(kFirstTime, store: Database.shared.userDefaults) private var firstTime: Bool = true

    @EnvironmentObject private var eventKitHandler: EventKitHandler
    @EnvironmentObject private var authenticationService: MCAuthenticationService
    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
    @EnvironmentObject private var controlState: ControlState

    @State private var isRefreshing = true

    @State private var refreshError: (any Error)?

    @State private var showLoginSheet = false

    @State private var fetchingDataFromServer = true

    private func tabViewContent(bottomPadding: CGFloat) -> some View {
        Group {
            if #available(iOS 18, *) {
                modernTabView(bottomPadding: bottomPadding)
            } else {
                legacyTabView(bottomPadding: bottomPadding)
            }
        }
        .compatTabBarMinimizeOnScroll()
        .task {
            await refreshAccessToken()
        }
        .task {
            if !firstTime {
                try? await contentServiceHandler.requestHealthKitAccess()
                _ = try? await eventKitHandler.requestAccess(for: .reminder)
                _ = try? await eventKitHandler.requestAccess(for: .event)
            }
        }
        .permissionsOnboardingSheet(showingSheet: $firstTime, fetchingData: $fetchingDataFromServer)
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

            Task<Void, Never> {
                fetchingDataFromServer = true
                defer { fetchingDataFromServer = false }

                do {
                    async let exercises: Void = contentServiceHandler.fetchUserExercises()
                    async let insights: Void = fetchDailyInsights()
                    async let mealPlan: Void = contentServiceHandler.fetchMealPlan()

                    _ = try await (exercises, insights, mealPlan)

                } catch {
                    controlState.error = error
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
        defer { isRefreshing = false }

        do {
            try await authenticationService.refresh()
        } catch {
            let refresh = await authenticationService.autoLogin()
            if refresh != nil {
                return
            }
            refreshError = RefreshError()
        }
    }

    private func fetchDailyInsights() async throws {
        while true {
            do {

                let networkResponse = try await MCContentRepository.shared.generateDailyInsights()

                contentServiceHandler.todayFocusText = networkResponse.data.todaysFocus
                contentServiceHandler.dailyTipText = networkResponse.data.dailyTip

                return

            } catch {
                if error is LongPolling {
                    continue
                } else {
                    throw error
                }
            }
        }
    }

    @available(iOS 18, *)
    private func modernTabView(bottomPadding: CGFloat) -> some View {
        TabView(selection: $controlState.selectedTab) {
            TabSection {
                Tab(AppTab.progress.title, systemImage: AppTab.progress.systemImage, value: AppTab.progress) {
                    NavigationStack { DashboardView() }
                        .safeAreaPadding(bottomPadding)
                }

                Tab(AppTab.myPlan.title, systemImage: AppTab.myPlan.systemImage, value: AppTab.myPlan) {
                    NavigationStack { MyPlanView() }
                        .safeAreaPadding(bottomPadding)
                }

                Tab(AppTab.triTrack.title, systemImage: AppTab.triTrack.systemImage, value: AppTab.triTrack) {
                    NavigationStack { TriTrackView() }
                        .safeAreaPadding(bottomPadding)
                }

                Tab(AppTab.mood.title, systemImage: AppTab.mood.systemImage, value: AppTab.mood) {
                    NavigationStack { MoodNestView() }
                        .safeAreaPadding(bottomPadding)
                }
            }

            Tab(AppTab.settings.title, systemImage: AppTab.settings.systemImage, value: AppTab.settings) {
                NavigationStack { ProfileView() }
                    .safeAreaPadding(bottomPadding)
            }
        }
    }

    private func legacyTabView(bottomPadding: CGFloat) -> some View {
        TabView(selection: $controlState.selectedTab) {

            NavigationStack {
                DashboardView()
                    .safeAreaPadding(bottomPadding)
            }
            .tabItem {
                Label(AppTab.progress.title, systemImage: AppTab.progress.systemImage)
            }
            .tag(AppTab.progress)

            NavigationStack {
                MyPlanView()
                    .safeAreaPadding(bottomPadding)
            }
            .tabItem {
                Label(AppTab.myPlan.title, systemImage: AppTab.myPlan.systemImage)
            }
            .tag(AppTab.myPlan)

            NavigationStack {
                TriTrackView()
                    .safeAreaPadding(bottomPadding)
            }
            .tabItem {
                Label(AppTab.triTrack.title, systemImage: AppTab.triTrack.systemImage)
            }
            .tag(AppTab.triTrack)

            NavigationStack {
                MoodNestView()
                    .safeAreaPadding(bottomPadding)
            }
            .tabItem {
                Label(AppTab.mood.title, systemImage: AppTab.mood.systemImage)
            }
            .tag(AppTab.mood)

            NavigationStack {
                ProfileView()
                    .safeAreaPadding(bottomPadding)
            }
            .tabItem {
                Label(AppTab.settings.title, systemImage: AppTab.settings.systemImage)
            }
            .tag(AppTab.settings)
        }
    }
}

extension View {
    @ViewBuilder
    func compatTabBarMinimizeOnScroll() -> some View {
        if #available(iOS 26, *) {
            self.tabBarMinimizeBehavior(.onScrollDown)
        } else {
            self
        }
    }
}
