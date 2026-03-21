import SwiftUI

struct SignInMissingFieldValue: LocalizedError {
    var errorDescription: String? {
        "Missing Field Value"
    }

    var failureReason: String? {
        "Please fill in all the fields before submitting the form."
    }

    var recoverySuggestion: String? {
        "Make sure to provide both your email address and password."
    }
}

struct SignInView: View {

    // MARK: Internal

    var body: some View {
        NavigationStack {
            signInForm
                .safeAreaInset(edge: .top) {
                    Color.clear.frame(height: 16)
                }

            .background(
                Color(.systemBackground)
                    .ignoresSafeArea()
            )
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        Task { await handleSubmit() }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Text("Sign In")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .tint(MomCareAccent.primary)
                    .controlSize(.large)
                    .accessibilityLabel("Sign In")
                    .accessibilityHint("Signs you in to your account")
                }
            }
            .navigationDestination(isPresented: $navigateToHealthMetricsSignUp) {
                HealthMetricsSignUpView()
            }
            .navigationDestination(isPresented: $navigateToOTPVerification) {
                OTPScreenView()
            }
        }
    }

    func handleSubmit() async {
        isLoading = true
        defer { isLoading = false }

        guard !emailAddress.isEmpty, !password.isEmpty else {
            controlState.error = SignInMissingFieldValue()
            return
        }

        do {
            try await authenticationService.login(emailAddress: emailAddress, password: password)
            let credentialsResponse = try await authenticationService.fetchCredentials()

            if let verified = credentialsResponse.data?.verified, !verified {
                navigateToOTPVerification = true
                return
            }

        } catch {
            controlState.error = error
            return
        }

        do {
            try await authenticationService.me()

            if authenticationService.userModel?.dateOfBirth == nil {
                navigateToHealthMetricsSignUp = true
            }
        } catch {
            controlState.error = error
        }
    }

    // MARK: Private

    @State private var isLoading: Bool = false

    @EnvironmentObject private var authenticationService: AuthenticationService
    @EnvironmentObject private var controlState: ControlState

    @State private var navigateToHealthMetricsSignUp = false
    @State private var navigateToOTPVerification = false

    @State private var emailAddress = ""
    @State private var password = ""

    @ViewBuilder
    private var signInForm: some View {
        Form {
            Section {
                emailField
                passwordField
            } footer: {
                if !isValidEmail(emailAddress) && !emailAddress.isEmpty {
                    Text("Please enter a valid email address.")
                        .foregroundColor(.red)
                        .accessibilityLabel("Invalid email address")
                        .accessibilityHint("The email address you entered is not valid. Please correct it before submitting.")
                }
            }
        }
        .scrollContentBackground(.hidden)
    }

    private var emailField: some View {
        TextField("Email Address", text: $emailAddress)
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

    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: email)
    }
}
