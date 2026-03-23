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
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Refresh Token Expired")
            .navigationSubtitle("HTTP 401 Unauthorized")
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
                        .accessibilityLabel("If you have an Apple ID linked to your account, you can use it to sign in quickly and securely without needing to enter your password.")

                        VStack(spacing: 12) {
                            SignInWithAppleButton(.continue) { request in
                                request.requestedScopes = []
                            } onCompletion: { _ in
                                Task {}
                            }
                            .signInWithAppleButtonStyle(.black)
                            .frame(height: 50)
                            .cornerRadius(24)
                            .accessibilityLabel("Sign in with Apple")

                            Button("Cancel") {
                                showAppleLoginSheet = false
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
                    Button(role: .cancel) {
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
                            } catch {}
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
                    .accessibilityLabel("Sign In")
                    .accessibilityHint("Signs you in to your account")
                }
            }
        }
    }

    // MARK: Private

    private enum Field { case email, password }

    @Environment(\.dismiss) private var dismiss

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false

    @State private var showAppleLoginSheet: Bool = false
    @EnvironmentObject private var authenticationService: AuthenticationService

    @FocusState private var focusedField: Field?

    private var emailField: some View {
        TextField("Email Address", text: $email)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .focused($focusedField, equals: .email)
            .autocorrectionDisabled()
            .listRowBackground(Color(.secondarySystemBackground))
            .accessibilityLabel("Email address")
            .accessibilityHint("Enter your email address")
    }

    private var passwordField: some View {
        SecureField("Password", text: $password)
            .listRowBackground(Color(.secondarySystemBackground))
            .accessibilityLabel("Password")
            .focused($focusedField, equals: .password)
            .accessibilityHint("Enter your password")
    }

    private func submitEmailLogin() async throws {
        try await authenticationService.login(emailAddress: email, password: password)
    }
}
