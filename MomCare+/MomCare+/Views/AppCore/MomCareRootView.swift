import SwiftUI

struct MomCareRootView: View {

    // MARK: Internal

    var body: some View {
        if let isProfileComplete = authenticationService.userModel?.isProfileComplete, isProfileComplete {
            MomCareMainTabView()
                .transition(reduceMotion ? .identity : .opacity)
                .preferredColorScheme(forceDarkMode ? .dark : (forceLightMode ? .light : nil))
        } else {
            OnboardingView()
                .transition(reduceMotion ? .identity : .opacity)
                .preferredColorScheme(forceDarkMode ? .dark : (forceLightMode ? .light : nil))
        }
    }

    // MARK: Private

    @AppStorage(FeatureFlagState.forceDarkMode.rawValue, store: UserDefaults(suiteName: "group.MomCare")) private var forceDarkMode: Bool = false
    @AppStorage(FeatureFlagState.forceLightMode.rawValue, store: UserDefaults(suiteName: "group.MomCare")) private var forceLightMode: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var authenticationService: AuthenticationService
}
