import SwiftUI

struct MomCareRootView: View {

    // MARK: Internal

    var body: some View {
        if let isProfileComplete = authenticationService.userModel?.isProfileComplete, isProfileComplete {
            MomCareMainTabView()
                .transition(.opacity)
                .preferredColorScheme(forceDarkMode ? .dark : (forceLightMode ? .light : nil))
        } else {
            OnboardingView()
                .transition(.opacity)
                .preferredColorScheme(forceDarkMode ? .dark : (forceLightMode ? .light : nil))
        }
    }

    // MARK: Private

    @AppStorage(FeatureFlagState.forceDarkMode.rawValue) private var forceDarkMode: Bool = false
    @AppStorage(FeatureFlagState.forceLightMode.rawValue) private var forceLightMode: Bool = true

    @EnvironmentObject private var authenticationService: AuthenticationService
}
