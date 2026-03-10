import SwiftUI

struct MomCareRootView: View {

    // MARK: Internal

    var body: some View {
        if let isProfileComplete = authenticationService.userModel?.isProfileComplete, isProfileComplete {
            MomCareMainTabView()
                .transition(.opacity)
                .preferredColorScheme(.light)
        } else {
            OnboardingView()
                .transition(.opacity)
                .preferredColorScheme(.light)
        }
    }

    // MARK: Private

    @EnvironmentObject private var authenticationService: AuthenticationService
}
