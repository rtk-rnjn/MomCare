import AuthenticationServices
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
                        Task {
                            try? await handleAppleSignIn(result)
                            _ = try? await authenticationService.me()
                            if authenticationService.userModel?.dueDateTimestamp == nil {
                                navigateToHealthMetricsSignUp = true
                            }

                        }
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 52)
                    .cornerRadius(14)
                    .padding(.horizontal, 20)

                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.gray.opacity(0.3))
                            .accessibilityHidden(true)

                        Text("OR")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.gray.opacity(0.3))
                            .accessibilityHidden(true)
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
                    .accessibilityLabel("Continue with Email")
                    .accessibilityHint("Sign in using your email address and password")
                    .accessibilityIdentifier("continueWithEmailButton")

                    HStack(spacing: 4) {
                        Text("Don’t have an account?")
                            .foregroundStyle(.secondary)

                        NavigationLink("Sign Up") {
                            BaseSignUpView()
                        }
                        .font(.body.weight(.semibold))
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
            .navigationDestination(isPresented: $navigateToHealthMetricsSignUp) {
                HealthMetricsSignUpView()
            }
        }

    }

    // MARK: Private

    @State private var navigateToHealthMetricsSignUp = false

    @EnvironmentObject private var authenticationService: AuthenticationService

    @State private var currentPage = 0
    @State private var showAlert = false
    @State private var alertMessage: String?

    private func handleAppleSignIn(_ result: Result<ASAuthorization, any Error>) async throws {
        switch result {
        case let .success(auth):
            guard
                let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = credential.identityToken,
                let tokenString = String(data: tokenData, encoding: .utf8)
            else {
                alertMessage = "Failed to extract Apple Sign-In token."
                showAlert = true
                return
            }

            _ = try await authenticationService.login(with: .apple, token: tokenString)

        case let .failure(error):
            alertMessage = "Apple Sign-In failed: \(error.localizedDescription)"
            showAlert = true
        }
    }
}
