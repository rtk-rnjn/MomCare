import LNPopupUI
import SwiftUI

struct MomCareMainTabView: View {

    // MARK: Internal

    var body: some View {
        tabViewContent(bottomPadding: 0)
            .tint(MomCareAccent.primary)
            .applyLiquidGlassTabBar()
    }

    // MARK: Private

    @EnvironmentObject private var authenticationService: AuthenticationService
    @EnvironmentObject private var musicKitHandler: MusicPlayerHandler
    @EnvironmentObject private var controlState: ControlState

    private func tabViewContent(bottomPadding: CGFloat) -> some View {
        TabView(selection: $controlState.selectedTab) {
            NavigationStack { DashboardView() }
                .tabItem { Label(AppTab.progressHub.title, systemImage: AppTab.progressHub.systemImage) }
                .tag(AppTab.progressHub)
                .modifier(BottomSafeAreaPaddingModifier(padding: bottomPadding))

            NavigationStack { MyPlanView() }
                .tabItem { Label(AppTab.myPlan.title, systemImage: AppTab.myPlan.systemImage) }
                .tag(AppTab.myPlan)
                .modifier(BottomSafeAreaPaddingModifier(padding: bottomPadding))

            NavigationStack { TriTrackView() }
                .tabItem { Label(AppTab.triTrack.title, systemImage: AppTab.triTrack.systemImage) }
                .tag(AppTab.triTrack)
                .modifier(BottomSafeAreaPaddingModifier(padding: bottomPadding))

            MoodNestView()
                .tabItem { Label(AppTab.moodNest.title, systemImage: AppTab.moodNest.systemImage) }
                .tag(AppTab.moodNest)
                .modifier(BottomSafeAreaPaddingModifier(padding: bottomPadding))
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
    }
}

private struct BottomSafeAreaPaddingModifier: ViewModifier {
    let padding: CGFloat

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.safeAreaPadding(.bottom, padding)
        } else {
            content.padding(.bottom, padding)
        }
    }
}

extension View {
    func applyLiquidGlassTabBar() -> some View {
        onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterial)
            appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)

            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
