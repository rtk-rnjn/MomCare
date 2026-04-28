import AuthenticationServices
import SwiftUI

struct ReAuthenticationSheetView: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    emailField
                    passwordField
                } header: {
                    Text("Client-Server out of sync")
                } footer: {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Well. This is awkward. For security reasons, we require you to re-authenticate. Please enter your credentials to continue.")

                        Button("Don't remember your password?") {
                            showAppleLoginSheet = true
                        }
                    }
                }
            }
            .errorAlert(error: $error)
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Refresh Token Expired")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAppleLoginSheet) {
                NavigationStack {
                    VStack(spacing: 12) {
                        VStack(spacing: 12) {
                            Image(systemName: "person.badge.shield.checkmark.fill")
                                .font(.largeTitle)
                                .imageScale(.large)
                                .foregroundStyle(.primary)
                                .padding(.bottom, 4)
                                .accessibilityHidden(true)

                            Text("Continue with Apple")
                                .font(.title2.weight(.semibold))
                                .accessibilityAddTraits(.isHeader)

                            Text("If you have an Apple ID linked to your account, you can use it to sign in quickly and securely without needing to enter your password.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, 32)
                        .padding(.horizontal, 28)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(String(localized: "a11y_apple_signin_existing_hint"))

                        VStack(spacing: 12) {
                            SignInWithAppleButton(.continue) { request in
                                request.requestedScopes = []
                            } onCompletion: { result in
                                Task {
                                    await handleAppleLogin(result)
                                }
                            }
                            .signInWithAppleButtonStyle(.black)
                            .frame(height: 50)
                            .cornerRadius(CornerRadius.outer)
                            .accessibilityLabel(String(localized: "a11y_apple_signin_label"))

                            Button("Cancel") {
                                showAppleLoginSheet = false
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 8)
                            .accessibilityHint(String(localized: "a11y_close_sheet_reauth_hint"))
                        }
                        .padding(.horizontal, 28)
                        .padding(.bottom, 24)
                    }
                    .navigationBarHidden(true)
                }
                .presentationDetents([.medium, .fraction(0.40)])
                .interactiveDismissDisabled()
            }
            .onAppear {
                email = authenticationService.credentials?.emailAddress ?? ""
                if email.isEmpty {
                    focusedField = .email
                } else {
                    focusedField = .password
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    MCCancelButton {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .bottomBar) {
                    Button {
                        Task {
                            isLoading = true
                            defer { isLoading = false }

                            do {
                                try await submitEmailLogin()
                                await MainActor.run {
                                    dismiss()
                                }
                            } catch {
                                self.error = error
                            }
                        }
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
                    .accessibilityLabel(String(localized: "a11y_sign_in_label"))
                    .accessibilityHint(String(localized: "a11y_sign_in_hint"))
                }
            }
        }
    }

    // MARK: Private

    private enum Field { case email, password }

    @State private var error: (any Error)?

    @Environment(\.dismiss) private var dismiss

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false

    @State private var showAppleLoginSheet: Bool = false
    @EnvironmentObject private var authenticationService: MCAuthenticationService

    @FocusState private var focusedField: Field?

    private var emailField: some View {
        TextField("Email Address", text: $email)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .focused($focusedField, equals: .email)
            .autocorrectionDisabled()
            .listRowBackground(Color(.secondarySystemBackground))
            .accessibilityLabel(String(localized: "a11y_email_label"))
            .accessibilityHint(String(localized: "a11y_enter_email_hint"))
    }

    private var passwordField: some View {
        SecureField("Password", text: $password)
            .listRowBackground(Color(.secondarySystemBackground))
            .accessibilityLabel(String(localized: "a11y_password_label"))
            .focused($focusedField, equals: .password)
            .accessibilityHint(String(localized: "a11y_enter_password_hint"))
    }

    private func submitEmailLogin() async throws {
        try await authenticationService.login(emailAddress: email, password: password)
    }

    private func handleAppleLogin(_ result: Result<ASAuthorization, any Error>) async {
        switch result {
        case let .success(auth):
            do {
                guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                      let tokenData = credential.identityToken,
                      let tokenString = String(data: tokenData, encoding: .utf8) else {
                    throw TokenParseError()
                }

                _ = try await authenticationService.appleLogin(idToken: tokenString)

                await MainActor.run {
                    dismiss()
                }
            } catch {
                self.error = error
            }

        case let .failure(error):
            self.error = error
        }
    }
}
