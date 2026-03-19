import SwiftUI

struct SignInView: View {

    // MARK: Internal

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                signInForm
                    .safeAreaInset(edge: .top) {
                        Color.clear
                            .frame(height: 16)
                    }

                VStack {
                    Button {
                        Task { await handleSubmit() }
                    } label: {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .tint(MomCareAccent.primary)
                    .controlSize(.large)
                    .accessibilityLabel("Sign In")
                    .accessibilityHint("Signs you in to your account")
                }
                .alert(alertTitle, isPresented: $showAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(alertMessage)
                }
                .padding(.horizontal)
                .padding(.top, 30)
                .padding(.bottom, 20)
            }
            .background(
                Color(.systemBackground)
                    .ignoresSafeArea()
            )
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(isPresented: $navigateToHealthMetricsSignUp) {
                HealthMetricsSignUpView()
            }
            .navigationDestination(isPresented: $navigateToOTPVerification) {
                OTPScreenView()
            }
        }
    }

    func handleSubmit() async {
        let tokenPairResponse = try? await authenticationService.login(emailAddress: email, password: password)
        let credentialsResponse = try? await authenticationService.fetchCredentials()

        guard let tokenPairResponse, let credentialsResponse else {
            alertTitle = "Error"
            alertMessage = "An unexpected error occurred. Please try again later."
            showAlert = true
            return
        }

        if let error = tokenPairResponse.errorMessage {
            alertTitle = "Sign In Failed"
            alertMessage = error
            showAlert = true
            return
        }

        showAlert = false
        controlState.isLoggedIn = true

        if let verified = credentialsResponse.data?.verified, !verified {
            navigateToOTPVerification = true
            return
        }

        if authenticationService.userModel?.dateOfBirth == nil {
            navigateToHealthMetricsSignUp = true
        }
    }

    // MARK: Private

    @EnvironmentObject private var authenticationService: AuthenticationService
    @EnvironmentObject private var controlState: ControlState

    @State private var navigateToHealthMetricsSignUp = false
    @State private var navigateToOTPVerification = false

    @State private var email = ""
    @State private var password = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""

    @ViewBuilder
    private var signInForm: some View {
        Form {
            Section {
                emailField
                passwordField
            }
        }
        .scrollContentBackground(.hidden)
    }

    private var emailField: some View {
        TextField("Email ID", text: $email)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .listRowBackground(Color(.secondarySystemBackground))
            .accessibilityLabel("Email address")
            .accessibilityHint("Enter your email address")
    }

    private var passwordField: some View {
        SecureField("Password", text: $password)
            .listRowBackground(Color(.secondarySystemBackground))
            .accessibilityLabel("Password")
            .accessibilityHint("Enter your password")
    }
}
