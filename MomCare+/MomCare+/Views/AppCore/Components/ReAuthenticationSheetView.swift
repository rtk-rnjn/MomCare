import SwiftUI
import AuthenticationServices

struct ReAuthenticationSheetView: View {

    // MARK: Internal

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.top, 8)
                        .padding(.horizontal, 28)

                    Divider()
                        .padding(.vertical, 24)
                        .padding(.horizontal, 28)

                    credentialsSection
                        .padding(.horizontal, 28)

                    dividerWithLabel
                        .padding(.vertical, 20)
                        .padding(.horizontal, 28)

                    appleSection
                        .padding(.horizontal, 28)
                        .padding(.bottom, 32)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Session Expired")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: Private

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isLoadingEmail: Bool = false
    @State private var isLoadingApple: Bool = false
    @State private var errorMessage: String? = nil

    @FocusState private var focusedField: Field?

    private enum Field { case email, password }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Client-Server out of sync", systemImage: "lock.rotation")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            Text("Well this is awkward. Please reauthenticate to continue using the app.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

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

    private var credentialsSection: some View {
        VStack(spacing: 0) {
            signInForm
            
            // Sign in button
            Button {
                Task { await submitEmailLogin() }
            } label: {
                Group {
                    if isLoadingEmail {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Sign In")
                            .font(.subheadline.weight(.semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.accentColor,
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .disabled(email.isEmpty || password.isEmpty || isLoadingEmail || isLoadingApple)
            .animation(.default, value: isLoadingEmail)
        }
        .animation(.default, value: errorMessage)
    }

    private var dividerWithLabel: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(height: 1)
            Text("or")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(height: 1)
        }
    }

    private var appleSection: some View {
        VStack(spacing: 10) {
            if isLoadingApple {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            } else {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = []
                } onCompletion: { result in
                    Task { await submitAppleLogin(result) }
                }
                .frame(height: 50)
                .cornerRadius(12)
                .disabled(isLoadingEmail || isLoadingApple)
            }
        }
    }

    private func submitEmailLogin() async {

    }

    private func submitAppleLogin(_ result: Result<ASAuthorization, any Error>) async {

    }
}
