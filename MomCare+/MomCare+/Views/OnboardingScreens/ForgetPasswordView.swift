import SwiftUI

typealias ForgetPasswordInvalidEmailFormat = SignInInvalidEmailAddress
typealias ForgetPasswordPasswordMismatch = PasswordMismatchError

private struct ForgetPasswordInvalidOTPFormat: LocalizedError {
    var errorDescription: String? {
        "Invalid OTP"
    }

    var failureReason: String? {
        "The OTP must be a 6-digit number."
    }

    var recoverySuggestion: String? {
        "Please enter a valid 6-digit OTP."
    }
}

private struct ForgetPasswordWeakPassword: LocalizedError {
    var errorDescription: String? {
        "Weak Password"
    }

    var failureReason: String? {
        "Your password does not meet the security requirements."
    }

    var recoverySuggestion: String? {
        "Please create a password that is at least 8 characters long and includes a mix of letters, numbers, and special characters."
    }
}

struct ForgetPasswordView: View {
    // MARK: Internal

    @Binding var showingForgetPasswordSheet: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Email Address", text: $emailAddress)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .focused($isEmailFieldFocused, equals: true)
                        .onSubmit {
                            if isValidInput() {
                                navigate = true
                            } else {
                                error = ForgetPasswordInvalidEmailFormat()
                            }
                        }
                        .submitLabel(.continue)
                        .accessibilityLabel("Email address")
                        .accessibilityHint("Enter the email address associated with your account")
                } footer: {
                    Text("If you know your Apple Relay Email, you can use it to reset your password.")
                        .font(.footnote)
                }
            }
            .errorAlert(error: $error)
            .scrollDismissesKeyboard(.immediately)
            .onAppear {
                isEmailFieldFocused = true
            }

            .navigationTitle("Forgot Password")
            .navigationSubtitle("Enter your email to receive a password reset code.")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $navigate) {
                ForgetPasswordOTPView(showingForgetPasswordSheet: $showingForgetPasswordSheet, emailAddress: $emailAddress)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                    .accessibilityLabel("Cancel")
                    .accessibilityHint("Closes the forgot password sheet")
                }

                ToolbarItem(placement: .bottomBar) {
                    Button {
                        if isValidInput() {
                            navigate = true
                        } else {
                            error = ForgetPasswordInvalidEmailFormat()
                        }
                    } label: {
                        Text("Continue")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .buttonStyle(.borderedProminent)
                    .tint(MomCareAccent.primary)
                    .accessibilityLabel("Continue")
                    .accessibilityHint("Sends a password reset code to your email address")
                }
            }
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss

    @FocusState private var isEmailFieldFocused: Bool
    @State private var emailAddress: String = ""
    @State private var navigate: Bool = false

    @State private var error: (any Error)?

    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: email)
    }

    private func isValidInput() -> Bool {
        !emailAddress.isEmpty && isValidEmail(emailAddress)
    }
}

struct ForgetPasswordOTPView: View {
    // MARK: Internal

    @Binding var showingForgetPasswordSheet: Bool

    @Binding var emailAddress: String

    var body: some View {
        Form {
            Section {
                TextField("Enter OTP", text: $otpCode)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .focused($isOTPFieldFocused, equals: true)
                    .onSubmit {
                        if isValidInput() {
                            navigate = true
                        } else {
                            error = ForgetPasswordInvalidOTPFormat()
                        }
                    }
                    .submitLabel(.continue)
                    .onChange(of: otpCode) {
                        if otpCode.count == 6 {
                            isOTPFieldFocused = false
                        }
                        otpCode = otpCode.filter { $0.isNumber }
                    }
                    .accessibilityLabel("One-time password")
                    .accessibilityHint("Enter the 6-digit code sent to your email address")
            } footer: {
                Text("A 6-digit OTP has been sent to \(emailAddress). Please enter it above to continue.")
                    .font(.footnote)
            }
        }
        .errorAlert(error: $error)
        .onAppear {
            isOTPFieldFocused = true
        }
        .task {
            do {
                _ = try await authenticationService.forgetPassword(emailAddress: emailAddress)
            } catch {
                self.error = error
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Verify OTP")
        .navigationSubtitle("Enter the OTP sent to your email address.")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigate) {
            ResetPasswordView(showingForgetPasswordSheet: $showingForgetPasswordSheet, emailAddress: $emailAddress, otpCode: $otpCode)
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    if isValidInput() {
                        navigate = true
                    } else {
                        error = ForgetPasswordInvalidOTPFormat()
                    }
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .buttonStyle(.borderedProminent)
                .tint(MomCareAccent.primary)
                .accessibilityLabel("Continue")
                .accessibilityHint("Verifies your one-time password and proceeds to reset your password")
            }
        }
    }

    // MARK: Private

    @State private var otpCode: String = ""
    @State private var navigate: Bool = false
    @FocusState private var isOTPFieldFocused: Bool

    @EnvironmentObject private var authenticationService: MCAuthenticationService

    @State private var error: (any Error)?

    private func isValidInput() -> Bool {
        otpCode.count == 6 && otpCode.allSatisfy { $0.isNumber }
    }
}

struct ResetPasswordView: View {
    // MARK: Internal

    @Binding var showingForgetPasswordSheet: Bool
    @Binding var emailAddress: String
    @Binding var otpCode: String

    var body: some View {
        Form {
            Section {
                SecureField("New Password", text: $newPassword)
                    .focused($focusedField, equals: .newPassword)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .confirmPassword
                    }
                    .autocapitalization(.none)
                    .accessibilityLabel("New password")
                    .accessibilityHint("Enter your new password")

                SecureField("Confirm Password", text: $confirmPassword)
                    .focused($focusedField, equals: .confirmPassword)
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil
                    }
                    .autocapitalization(.none)
                    .accessibilityLabel("Confirm password")
                    .accessibilityHint("Re-enter your new password to confirm it matches")
            } footer: {
                Text("Your new password must be at least 8 characters long and include a mix of letters, numbers, and special characters.")
                    .font(.footnote)
            }
        }
        .errorAlert(error: $error)
        .scrollDismissesKeyboard(.immediately)
        .onAppear {
            focusedField = .newPassword
        }
        .alert("Success", isPresented: $success) {
            Button("OK") {
                showingForgetPasswordSheet = false
            }
        } message: {
            Text("Your password has been reset successfully. Please use your new password to sign in.")
        }
        .navigationTitle("Reset Password")
        .navigationBarTitleDisplayMode(.inline)
        .navigationSubtitle("Enter your new password below.")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    if isValidInput() {
                        resetPassword()
                    }
                } label: {
                    Text("Reset")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .buttonStyle(.borderedProminent)
                .tint(MomCareAccent.primary)
                .accessibilityLabel("Reset password")
                .accessibilityHint("Saves your new password")
            }
        }
    }

    // MARK: Private

    private enum Field {
        case newPassword
        case confirmPassword
    }

    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    @FocusState private var focusedField: Field?

    @EnvironmentObject private var authenticationService: MCAuthenticationService

    @State private var success: Bool = false

    @State private var error: (any Error)?

    private func isValidInput() -> Bool {
        guard newPassword == confirmPassword else {
            error = ForgetPasswordPasswordMismatch()
            return false
        }

        if newPassword.count < 8 {
            error = ForgetPasswordWeakPassword()
            return false
        }

        return true
    }

    private func resetPassword() {
        Task {
            do {
                _ = try await authenticationService.resetPassword(emailAddress: emailAddress, otp: otpCode, newPassword: newPassword)
                success = true
            } catch {
                self.error = error
            }
        }
    }
}
