import AuthenticationServices
import SwiftUI

struct PasswordFieldsEmptyError: LocalizedError {
    var errorDescription: String? {
        NSLocalizedString(
            "Please fill all password fields.",
            comment: "Error shown when one or more password fields are empty"
        )
    }

    var failureReason: String? {
        NSLocalizedString(
            "One or more required password fields are missing.",
            comment: "Reason explaining that the password fields were not completed"
        )
    }

    var recoverySuggestion: String? {
        NSLocalizedString(
            "Enter your current password, new password, and confirmation password to continue.",
            comment: "Suggestion telling the user how to fix the empty password fields error"
        )
    }
}

struct PasswordMismatchError: LocalizedError {
    var errorDescription: String? {
        NSLocalizedString(
            "New passwords do not match.",
            comment: "Error shown when the new password and confirmation password do not match"
        )
    }

    var failureReason: String? {
        NSLocalizedString(
            "The confirmation password is different from the new password.",
            comment: "Reason explaining that the password confirmation failed"
        )
    }

    var recoverySuggestion: String? {
        NSLocalizedString(
            "Make sure both password fields contain the same value.",
            comment: "Suggestion telling the user to re-enter matching passwords"
        )
    }
}

struct PasswordTooShortError: LocalizedError {
    var errorDescription: String? {
        NSLocalizedString(
            "Password must be at least 6 characters.",
            comment: "Error shown when the password length requirement is not met"
        )
    }

    var failureReason: String? {
        NSLocalizedString(
            "The password does not meet the minimum length requirement.",
            comment: "Reason explaining that the password is too short"
        )
    }

    var recoverySuggestion: String? {
        NSLocalizedString(
            "Use a password with at least 6 characters.",
            comment: "Suggestion telling the user how to fix the short password error"
        )
    }
}

struct TokenParseError: LocalizedError {
    var errorDescription: String? {
        NSLocalizedString(
            "Failed to parse Apple Sign-In token.",
            comment: "Error shown when the app fails to extract the token from the Apple Sign-In credential"
        )
    }

    var failureReason: String? {
        NSLocalizedString(
            "The app could not extract a valid token from the Apple Sign-In response.",
            comment: "Reason explaining that the Apple Sign-In token parsing failed"
        )
    }

    var recoverySuggestion: String? {
        NSLocalizedString(
            "Please try signing in with Apple again. If the problem persists, contact support.",
            comment: "Suggestion telling the user how to fix the Apple Sign-In token parsing error"
        )
    }
}

struct ProfileAccountSecurityView: View {
    // MARK: Internal

    var hasAppleIdentifier: Bool {
        authenticationService.credentials?.appleIdentifier != nil
    }

    var body: some View {
        List {
            if !emailAddress.isEmpty || !hasAppleIdentifier {
                Section {
                    HStack {
                        Text("Email Address")

                        Spacer()

                        Text(emailAddress)
                            .lineLimit(1)
                            .multilineTextAlignment(.trailing)
                            .autocorrectionDisabled()
                            .minimumScaleFactor(0.8)
                            .truncationMode(.middle)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Email Address: \(emailAddress)")

                } header: {
                    Text("Account Information")
                } footer: {
                    if !hasAppleIdentifier {
                        Text("Your email address is used for account recovery and notifications.")
                            .font(.footnote)
                    } else {
                        Text("This account is connected with Apple Sign-In. Email address is not required.")
                            .font(.footnote)
                    }
                }

                Section {
                    Button {
                        toggleChangePassword()
                    } label: {
                        HStack {
                            Text("Change Password")
                            Spacer()
                            Image(systemName: isChangingPassword ? "chevron.down" : "chevron.right")
                                .foregroundStyle(.secondary)
                                .contentTransition(reduceMotion ? .identity : .symbolEffect)
                                .animation(
                                    reduceMotion ? nil : .easeInOut,
                                    value: isChangingPassword
                                )
                        }
                    }
                    .foregroundStyle(.primary)
                    .accessibilityHint(isChangingPassword ? "Collapses the password change form" : "Expands the password change form")

                    if isChangingPassword {
                        SecureFieldRow(title: "Old Password", text: $oldPassword)
                        SecureFieldRow(title: "New Password", text: $newPassword)
                        SecureFieldRow(title: "Confirm Password", text: $confirmPassword)

                        Button {
                            validatePasswordAndSubmit {
                                do {
                                    _ = try await authenticationService.changePassword(
                                        currentPassword: oldPassword,
                                        newPassword: newPassword
                                    )
                                    await authenticationService.logout()
                                } catch {
                                    controlState.error = error
                                }
                            }
                        } label: {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color("primaryAppColor")))
                            } else {
                                Text("Change")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(canSubmit ? Color("primaryAppColor") : .secondary)
                        .disabled(!canSubmit)
                        .onAppear {
                            if let password = KeychainHelper.get(.password) {
                                oldPassword = password
                            }
                        }
                        .accessibilityLabel("Change password")
                        .accessibilityHint("Submits the new password")
                    }
                } header: {
                    Text("Security")
                } footer: {
                    let text = isChangingPassword ? "Your password must be at least 6 characters long. Make sure to choose a strong password to keep your account secure." : "Changing your password will log you out of all devices. You will need to sign in again with your new password."

                    Text(text)
                        .font(.footnote)
                        .foregroundStyle(isChangingPassword ? .secondary : Color.red)
                        .contentTransition(reduceMotion ? .identity : .interpolate)
                        .animation(reduceMotion ? nil : .interpolatingSpring, value: text)
                }
            } else {
                Section {
                    if hasAppleIdentifier {
                        Text("This account is connected with Apple Sign-In.")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("No email address associated with this account.")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Account Information")
                }
            }
            Section {
                HStack {
                    Text("Apple ID")
                    Spacer()
                    Button {
                        showAppleConnectSheet = true
                    } label: {
                        if hasAppleIdentifier {
                            Text("Connected")
                                .foregroundStyle(.red)
                        } else {
                            Text("Connect")
                                .foregroundStyle(.black)
                        }
                    }
                    .disabled(hasAppleIdentifier)
                    .accessibilityLabel(hasAppleIdentifier ? "Apple ID: Connected" : "Apple ID: Not connected")
                    .accessibilityHint(hasAppleIdentifier ? "" : "Double tap to connect your Apple ID")
                }
            } header: {
                Text("Third Party Integration")
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .listStyle(.insetGrouped)
        .sheet(isPresented: $showAppleConnectSheet) {
            NavigationStack {
                VStack(spacing: 12) {
                    VStack(spacing: 12) {
                        Image(systemName: "person.badge.shield.checkmark.fill")
                            .font(.largeTitle)
                            .imageScale(.large)
                            .foregroundStyle(.primary)
                            .padding(.bottom, 4)
                            .accessibilityHidden(true)

                        Text("Connect with Apple")
                            .font(.title2.weight(.semibold))
                            .accessibilityAddTraits(.isHeader)

                        Text("Link your Apple ID to sign in quickly and keep your account secure.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 32)
                    .padding(.horizontal, 28)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Connect with Apple. Link your Apple ID to sign in quickly and keep your account secure.")

                    VStack(spacing: 12) {
                        SignInWithAppleButton(.continue) { request in
                            request.requestedScopes = []
                        } onCompletion: { result in
                            Task { await handleAppleSignIn(result) }
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 50)
                        .cornerRadius(24)
                        .accessibilityLabel("Sign in with Apple")

                        Button("Cancel") {
                            showAppleConnectSheet = false
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)
                        .accessibilityHint("Closes this sheet")
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 24)
                }
                .navigationBarHidden(true)
            }
            .presentationDetents([.medium, .fraction(0.40)])
            .interactiveDismissDisabled()
        }
        .navigationTitle("Account & Security")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            let credentials = authenticationService.credentials
            emailAddress = credentials?.emailAddress ?? ""
        }
    }

    func toggleChangePassword() {
        withAnimation(reduceMotion ? nil : .easeInOut) {
            isChangingPassword.toggle()
        }
    }

    func validatePasswordAndSubmit(completion: (() async -> Void)? = nil) {
        isLoading = true
        defer { isLoading = false }

        guard canSubmit else {
            controlState.error = PasswordFieldsEmptyError()
            return
        }
        guard newPassword == confirmPassword else {
            controlState.error = PasswordMismatchError()
            return
        }
        guard newPassword.count >= 6 else {
            controlState.error = PasswordTooShortError()
            return
        }

        Task {
            await completion?()
        }
    }

    // MARK: Private

    @State private var isLoading = false

    @State private var emailAddress: String = ""

    @EnvironmentObject private var authenticationService: MCAuthenticationService
    @EnvironmentObject private var controlState: ControlState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isChangingPassword = false

    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""

    @State private var showAppleConnectSheet: Bool = false

    private var canSubmit: Bool {
        !newPassword.isEmpty &&
        !confirmPassword.isEmpty
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, any Error>) async {
        switch result {
        case let .success(auth):
            do {
                guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                      let tokenData = credential.identityToken,
                      let tokenString = String(data: tokenData, encoding: .utf8) else {
                    throw TokenParseError()
                }

                _ = try await authenticationService.appleLogin(idToken: tokenString, existingEmailAddress: emailAddress)
            } catch {
                controlState.error = error
            }
            showAppleConnectSheet = false

        case let .failure(error):
            controlState.error = error
        }
    }
}

struct SecureFieldRow: View {
    let title: String

    @Binding var text: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            SecureField("", text: $text)
                .multilineTextAlignment(.trailing)
                .accessibilityLabel(title)
        }
    }
}
