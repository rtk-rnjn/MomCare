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
                        .accessibilityLabel(String(localized: "a11y_email_label"))
                        .accessibilityHint(String(localized: "a11y_forget_email_hint"))
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
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $navigate) {
                ForgetPasswordOTPView(showingForgetPasswordSheet: $showingForgetPasswordSheet, emailAddress: $emailAddress)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    MCCancelButton {
                        dismiss()
                    }
                    .accessibilityLabel(String(localized: "Cancel"))
                    .accessibilityHint(String(localized: "a11y_close_forget_password_hint"))
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
                    .accessibilityLabel(String(localized: "a11y_continue_label"))
                    .accessibilityHint(String(localized: "a11y_send_reset_code_hint"))
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
                    .accessibilityLabel(String(localized: "a11y_otp_field_label"))
                    .accessibilityHint(String(localized: "a11y_enter_otp_hint"))
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
                .accessibilityLabel(String(localized: "a11y_continue_label"))
                .accessibilityHint(String(localized: "a11y_verify_otp_proceed_hint"))
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
                    .accessibilityLabel(String(localized: "a11y_new_password_label"))
                    .accessibilityHint(String(localized: "a11y_new_password_hint"))

                SecureField("Confirm Password", text: $confirmPassword)
                    .focused($focusedField, equals: .confirmPassword)
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil
                    }
                    .autocapitalization(.none)
                    .accessibilityLabel(String(localized: "a11y_confirm_password_label"))
                    .accessibilityHint(String(localized: "a11y_confirm_new_password_hint"))
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
                .accessibilityLabel(String(localized: "a11y_reset_password_label"))
                .accessibilityHint(String(localized: "a11y_save_new_password_hint"))
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
