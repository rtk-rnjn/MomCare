import SwiftUI

struct BaseSignUpInvalidEmail: LocalizedError {
    var errorDescription: String? {
        "Invalid email address"
    }

    var failureReason: String? {
        "The email address you entered is not valid. Please check the format and try again."
    }

    var recoverySuggestion: String? {
        "Make sure your email address includes an '@' symbol and a domain (e.g., 'example.com')."
    }
}

struct BaseSignUpPasswordMissmatch: LocalizedError {
    var errorDescription: String? {
        "Password mismatch"
    }

    var failureReason: String? {
        "The password and confirm password fields do not match. Please ensure both fields contain the same password."
    }

    var recoverySuggestion: String? {
        "Re-enter the same password in both fields to proceed."
    }
}

struct BaseSignUpWeakPassword: LocalizedError {
    var errorDescription: String? {
        "Weak password"
    }

    var failureReason: String? {
        "Your password must be at least 8 characters long. Please choose a stronger password to enhance the security of your account."
    }

    var recoverySuggestion: String? {
        "Consider using a mix of uppercase letters, lowercase letters, numbers, and special characters to create a stronger password."
    }
}

struct BaseSignUpMissingFields: LocalizedError {
    let fields: [String]

    var errorDescription: String? {
        "Missing required fields"
    }

    var failureReason: String? {
        "Please fill in the following fields: \(fields.joined(separator: ", "))."
    }

    var recoverySuggestion: String? {
        "Make sure to complete all required fields before proceeding."
    }
}

struct BaseSignUpView: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                signUpForm
                    .safeAreaInset(edge: .top) {
                        Color.clear.frame(height: 16)
                    }
            }
            .background(
                Color(.systemBackground)
                    .ignoresSafeArea()
            )
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.large)
            .errorAlert(error: $controlState.error)
            .navigationDestination(isPresented: $navigateToOTP) {
                OTPScreenView()
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        Task {
                            do {
                                try await handleCreate()
                            } catch {
                                controlState.error = error
                            }
                        }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Text("Create")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .tint(MomCareAccent.primary)
                    .controlSize(.large)
                    .accessibilityLabel("Create account")
                    .accessibilityHint("Creates your new account")
                }
            }
        }
    }

    // MARK: Private

    private enum Field {
        case fullName
        case email
        case password
        case confirmPassword
    }

    private enum PasswordFieldType: String {
        case password = "Password"
        case confirmPassword = "Confirm Password"
    }

    @EnvironmentObject private var authenticationService: MCAuthenticationService
    @EnvironmentObject private var controlState: ControlState

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var showPassword = false
    @State private var showConfirmPassword = false

    @State private var navigateToOTP = false
    @State private var isLoading = false

    @FocusState private var isFocused: Field?

    private var signUpForm: some View {
        Group {
            Form {
                Section {
                    TextField("Full Name", text: $fullName)
                        .textInputAutocapitalization(.words)
                        .listRowBackground(Color(.secondarySystemBackground))
                        .focused($isFocused, equals: .fullName)
                        .onSubmit {
                            isFocused = .email
                        }
                        .submitLabel(.next)
                        .accessibilityLabel("Full name")
                        .accessibilityHint("Enter your full name")
                }

                Section {
                    TextField("Email Address", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .listRowBackground(Color(.secondarySystemBackground))
                        .focused($isFocused, equals: .email)
                        .onSubmit {
                            isFocused = .password
                        }
                        .submitLabel(.next)
                        .accessibilityLabel("Email address")
                        .accessibilityHint("Enter your email address")
                } footer: {
                    if !email.isEmpty, !isValidEmail(email), isFocused != .email {
                        Text("Please enter a valid email address")
                            .foregroundStyle(.red)
                            .accessibilityLabel("Email error: Please enter a valid email address")
                    }
                }
                .animation(reduceMotion ? nil : .easeInOut, value: email)

                Section {
                    passwordField(
                        text: $password,
                        isVisible: $showPassword,
                        type: .password
                    )

                    passwordField(
                        text: $confirmPassword,
                        isVisible: $showConfirmPassword,
                        type: .confirmPassword
                    )
                } footer: {
                    if !password.isEmpty, password.count < 8, isFocused != .password {
                        Text("Password must be at least 8 characters long")
                            .foregroundStyle(.red)
                            .accessibilityLabel("Password error: Password must be at least 8 characters long")
                    } else if !confirmPassword.isEmpty, confirmPassword != password, isFocused != .confirmPassword {
                        Text("Passwords do not match")
                            .foregroundStyle(.red)
                            .accessibilityLabel("Password error: Passwords do not match")
                    }
                }
                .contentTransition(reduceMotion ? .identity : .interpolate)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: password)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: confirmPassword)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollContentBackground(.hidden)
        }
    }

    private func passwordField(
        text: Binding<String>,
        isVisible: Binding<Bool>,
        type: PasswordFieldType
    ) -> some View {
        HStack {
            ZStack {
                SecureField(type.rawValue, text: text)
                    .opacity(isVisible.wrappedValue ? 0 : 1)
                    .accessibilityHidden(isVisible.wrappedValue)

                TextField(type.rawValue, text: text)
                    .opacity(isVisible.wrappedValue ? 1 : 0)
                    .accessibilityHidden(!isVisible.wrappedValue)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
            }
            .focused($isFocused, equals: type == .confirmPassword ? .confirmPassword : .password)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: isVisible.wrappedValue)
            .onSubmit {
                if type == .password {
                    isFocused = .confirmPassword
                } else if type == .confirmPassword {
                    isFocused = nil
                }
            }
            .submitLabel(.next)

            Button {
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                    isVisible.wrappedValue.toggle()
                }
            } label: {
                let iconName = isVisible.wrappedValue ? "eye.slash" : "eye"
                if reduceMotion {
                    Image(systemName: iconName)
                        .foregroundStyle(.secondary)
                } else {
                    Image(systemName: iconName)
                        .foregroundStyle(.secondary)
                        .symbolEffect(.bounce.down, options: .nonRepeating, value: isVisible.wrappedValue)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isVisible.wrappedValue ? "Hide \(type.rawValue.lowercased())" : "Show \(type.rawValue.lowercased())")
        }
        .listRowBackground(Color(.secondarySystemBackground))
    }

    private func communicateWithServer() async throws {
        try await authenticationService.register(emailAddress: email, password: password)

        let nameComponentFormatter = PersonNameComponentsFormatter()
        let nameComponents = nameComponentFormatter.personNameComponents(from: fullName)
        let firstName = nameComponents?.givenName ?? ""
        let lastName = nameComponents?.familyName ?? ""

        authenticationService.userModel?.firstName = firstName
        authenticationService.userModel?.lastName = lastName

        navigateToOTP = authenticationService.hasAccessToken
        _ = try await authenticationService.update(firstName: .value(firstName), lastName: .value(lastName))
    }

    private func handleCreate() async throws {
        isLoading = true
        defer { isLoading = false }

        let missingFields = getMissingFields()
        if !missingFields.isEmpty {
            throw BaseSignUpMissingFields(fields: missingFields)
        }

        guard isValidEmail(email) else {
            throw BaseSignUpInvalidEmail()
        }
        guard password == confirmPassword else {
            throw BaseSignUpPasswordMissmatch()
        }
        guard password.count >= 8 else {
            throw BaseSignUpWeakPassword()
        }

        try await communicateWithServer()

        navigateToOTP = true
    }

    private func getMissingFields() -> [String] {
        var missing = [String]()

        if email.isEmpty {
            missing.append("Email Address")
        }
        if password.isEmpty {
            missing.append("Password")
        }
        if confirmPassword.isEmpty {
            missing.append("Confirm Password")
        }

        return missing
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: email)
    }
}
