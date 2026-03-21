import SwiftUI

struct MomCareRootView: View {

    // MARK: Internal

    var body: some View {
        if isLoggedIn {
            MomCareMainTabView()
                .preferredColorScheme(colorScheme)

        } else {
            OnboardingView()
                .preferredColorScheme(colorScheme)
        }
    }

    // MARK: Private

    @AppStorage(FeatureFlagState.forceDarkMode.rawValue, store: UserDefaults(suiteName: "group.MomCare"))
    private var forceDarkMode: Bool = false

    @AppStorage(FeatureFlagState.forceLightMode.rawValue, store: UserDefaults(suiteName: "group.MomCare"))
    private var forceLightMode: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var authenticationService: AuthenticationService

    private var isLoggedIn: Bool {
        guard let userModel = authenticationService.userModel else {
            return false
        }

        return userModel.isProfileComplete
    }

    private var colorScheme: ColorScheme? {
        if forceDarkMode {
            return .dark
        }

        if forceLightMode {
            return .light
        }

        return nil
    }

}
