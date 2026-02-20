import SwiftUI

struct MomCareRootView: View {
    @EnvironmentObject var authenticationService: AuthenticationService

    var body: some View {
        if let isProfileComplete = authenticationService.userModel?.isProfileComplete, isProfileComplete {
            MomCareMainTabView()
                .transition(.opacity)
        } else {
            OnboardingView()
                .transition(.opacity)
        }
    }
}
