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

struct SignInInvalidEmailAddress: LocalizedError {
    var errorDescription: String? {
        "Invalid Email Address"
    }

    var failureReason: String? {
        "The email address you entered is not valid."
    }

    var recoverySuggestion: String? {
        "Please enter a valid email address in the format 'example@domain.com'."
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
            .errorAlert(error: $controlState.error)
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
            .sheet(isPresented: $showForgetPasswordSheet) {
                ForgetPasswordView(showingForgetPasswordSheet: $showForgetPasswordSheet)
                    .presentationDetents([.medium, .large])
                    .interactiveDismissDisabled()
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
        guard isValidEmail(emailAddress) else {
            controlState.error = SignInInvalidEmailAddress()
            return
        }

        do {
            try await authenticationService.login(emailAddress: emailAddress, password: password)
            let credentialsResponse = try await authenticationService.fetchCredentials()

            let verified = credentialsResponse.data.verified
            if !verified {
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

    private enum Field {
        case email
        case password
    }

    @State private var isLoading: Bool = false

    @EnvironmentObject private var authenticationService: MCAuthenticationService
    @EnvironmentObject private var controlState: ControlState

    @State private var navigateToHealthMetricsSignUp = false
    @State private var navigateToOTPVerification = false

    @State private var showForgetPasswordSheet = false

    @State private var emailAddress = ""
    @State private var password = ""

    @FocusState private var focusedField: Field?

    private var signInForm: some View {
        Form {
            Section {
                emailField
                passwordField
            } footer: {
                HStack {
                    Spacer()

                    Button {
                        showForgetPasswordSheet = true
                    } label: {
                        Text("Forget Password?")
                            .foregroundStyle(.primaryApp)
                    }
                    .accessibilityHint("Reset your password")
                }
            }
        }
        .onAppear {
            focusedField = .email
        }
        .scrollDismissesKeyboard(.interactively)
        .scrollContentBackground(.hidden)
    }

    private var emailField: some View {
        TextField("Email Address", text: $emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .listRowBackground(Color(.secondarySystemBackground))
            .focused($focusedField, equals: .email)
            .onSubmit {
                focusedField = .password
            }
            .submitLabel(.next)
            .accessibilityLabel("Email address")
            .accessibilityHint("Enter your email address")
    }

    private var passwordField: some View {
        SecureField("Password", text: $password)
            .listRowBackground(Color(.secondarySystemBackground))
            .focused($focusedField, equals: .password)
            .onSubmit {
                Task { await handleSubmit() }
            }
            .submitLabel(.go)
            .accessibilityLabel("Password")
            .accessibilityHint("Enter your password")
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: email)
    }
}
