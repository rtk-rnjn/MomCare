import SwiftUI
import AuthenticationServices

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
            .sheet(isPresented: $showAppleLoginSheet, onDismiss: {}, content: {
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
            })
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .bottomBar) {
                    Button {
                        Task {}
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
    @State private var isPasswordVisible: Bool = false
    @State private var isLoading: Bool = false

    @State private var showAppleLoginSheet: Bool = false

    @FocusState private var focusedField: Field?

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

    private func submitEmailLogin() async {}

    private func submitAppleLogin(_ result: Result<ASAuthorization, any Error>) async {}
}
