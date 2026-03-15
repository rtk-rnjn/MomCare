import SwiftUI

struct MomCareRootView: View {

    @AppStorage(FeatureFlagState.forceDarkMode.rawValue) private var forceDarkMode: Bool = false
    @AppStorage(FeatureFlagState.forceLightMode.rawValue) private var forceLightMode: Bool = true

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

    @EnvironmentObject private var authenticationService: AuthenticationService
}
