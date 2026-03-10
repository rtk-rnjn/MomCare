import SwiftUI

struct MomCareRootView: View {

    // MARK: Internal

    var body: some View {
        if let isProfileComplete = authenticationService.userModel?.isProfileComplete, isProfileComplete {
            MomCareMainTabView()
                .transition(.opacity)
        } else {
            OnboardingView()
                .transition(.opacity)
        }
    }

    // MARK: Private

    @EnvironmentObject private var authenticationService: AuthenticationService

}
