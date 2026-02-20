

import AuthenticationServices
import GoogleSignIn
import SwiftUI

struct OnboardingView: View {

    // MARK: Internal

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                HStack {
                    Text("MomCare+")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(MomCareAccent.primary)

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 45)

                TabView(selection: $currentPage) {
                    ForEach(Array(onboardingPages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .padding(.bottom, 20)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .frame(maxHeight: 500)

                VStack(spacing: 18) {
                    SignInWithAppleButton(.continue) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        handleAppleSignIn(result)
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 52)
                    .cornerRadius(14)
                    .padding(.horizontal, 20)

                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.gray.opacity(0.3))

                        Text("OR")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.gray.opacity(0.3))
                    }
                    .padding(.horizontal, 20)

                    NavigationLink(destination: SignInView()) {
                        Text("Continue with Email")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(MomCareAccent.primary)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 20)

                    HStack(spacing: 4) {
                        Text("Don’t have an account?")
                            .foregroundStyle(.secondary)

                        NavigationLink("Sign Up") {
                            BaseSignUpView()
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(MomCareAccent.primary)
                    }
                    .font(.subheadline)
                    .padding(.top, 4)
                }
                .padding(.bottom, 20)
            }
            .background(
                Color("secondaryAppColor")
                    .ignoresSafeArea()
            )
            .navigationDestination(isPresented: $navigateToSecondSignup) {
                HealthMetricsSignUpView()
            }
            .fullScreenCover(isPresented: $navigateToMainApp) {
                MomCareMainTabView()
            }
            .alert("Found Login Credentials", isPresented: $authenticationService.hasAccessToken) {
                Button("Login") {
                    if let isProfileComplete = authenticationService.userModel?.isProfileComplete, isProfileComplete {
                        navigateToMainApp = true
                    } else {
                        navigateToSecondSignup = true
                    }
                }
                Button("Use Different Account", role: .cancel) {
                    Task { _ = await authenticationService.logout() }
                }
            } message: {
                Text("We found existing login credentials saved on this device. Would you like to continue with those?")
            }
            .alert("Login Failed", isPresented: $showAlert) {
                Button("OK", role: .cancel) {
                    showAlert = false
                    Task { _ = await authenticationService.logout() }
                }
            } message: {
                Text(alertMessage ?? "An unknown error occurred during login.")
            }
            .task {
                guard let networkResponse = await authenticationService.autoLogin() else {
                    return
                }

                if let error = networkResponse.errorMessage {
                    showAlert = true
                    alertMessage = error
                }
            }
        }
    }

    // MARK: Private

    @EnvironmentObject private var authenticationService: AuthenticationService

    @State private var currentPage = 0
    @State private var navigateToSecondSignup = false
    @State private var navigateToMainApp = false
    @State private var showAlert = false
    @State private var alertMessage: String? = nil

    private func handleAppleSignIn(_ result: Result<ASAuthorization, any Error>) {
        switch result {
        case let .success(auth):
            guard
                let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = credential.identityToken,
                let tokenString = String(data: tokenData, encoding: .utf8)
            else {
                print("Failed to fetch Apple identity token")
                return
            }

            print("Apple Sign-In success, token:", tokenString)

            let isNewUser = true

            DispatchQueue.main.async {
                if isNewUser {
                    navigateToSecondSignup = true
                } else {
                    navigateToMainApp = true
                }
            }

        case let .failure(error):
            print("Apple Sign-In failed:", error.localizedDescription)
        }
    }
}
