import SwiftUI
import AuthenticationServices

struct ProfileAccountSecurityView: View {

    // MARK: Internal

    var canSubmit: Bool {
        !newPassword.isEmpty &&
        !confirmPassword.isEmpty
    }

    var body: some View {
        List {
            Section {
                editableRow(
                    title: "Email Address",
                    text: $emailAddress,
                    keyboard: .emailAddress
                )

            } header: {
                Text("Account Information")
            } footer: {
                Text("Your email address is used for account recovery and notifications. Make sure to keep it up to date and secure.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            Section {
                Button {
                    toggleChangePassword()
                } label: {
                    HStack {
                        Text("Change Password")
                        Spacer()
                        Image(systemName: isChangingPassword ? "chevron.down" : "chevron.right")
                            .foregroundColor(.secondary)
                            .contentTransition(reduceMotion ? .identity : .symbolEffect)
                            .animation(
                                reduceMotion ? nil : .spring(response: 0.25, dampingFraction: 0.8),
                                value: isChangingPassword
                            )
                    }
                }
                .foregroundColor(.primary)
                .accessibilityHint(isChangingPassword ? "Collapses the password change form" : "Expands the password change form")

                if isChangingPassword {

                    SecureFieldRow(title: "Old Password", text: $oldPassword)
                    SecureFieldRow(title: "New Password", text: $newPassword)
                    SecureFieldRow(title: "Confirm Password", text: $confirmPassword)

                    if let error = errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.vertical, 4)
                    }

                    Button("Change") {
                        validatePasswordAndSubmit {
                            do {
                                _ = try await authenticationService.changePassword(
                                    currentPassword: oldPassword,
                                    newPassword: newPassword
                                )
                            } catch {
                                alertMessage = error.localizedDescription
                                showAlert = true
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(canSubmit ? Color("primaryAppColor") : .secondary)
                    .disabled(!canSubmit)
                }
            } header: {
                Text("Security")
            } footer: {
                Text("Your password must be at least 6 characters long. Make sure to choose a strong password to keep your account secure.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
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
                                .foregroundColor(.red)
                        } else {
                            Text("Connect")
                                .foregroundColor(.green)
                        }
                    }
                    .disabled(hasAppleIdentifier)
                }
            } header: {
                Text("Third Party Integration")
            }
        }
        .listStyle(.insetGrouped)
        .sheet(isPresented: $showAppleConnectSheet) {
            NavigationStack {
                HStack {
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = []
                    } onCompletion: { result in
                        Task {
                            try? await handleAppleSignIn(result)
                        }
                    }
                }
                .navigationTitle("Connect with Apple")
                .navigationSubtitle("Secure your account")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .cancel) {
                            showAppleConnectSheet = false
                        }
                    }
                }
                .presentationDetents([.medium, .fraction(0.25)])
                .interactiveDismissDisabled()
            }
        }
        .navigationTitle("Account & Security")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "An unexpected error occurred.")
        }

        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    if reduceMotion {
                        isEditing.toggle()
                    } else {
                        withAnimation {
                            isEditing.toggle()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(MomCareAccent.primary)
            }
        }
        .onAppear {
            let credentials = authenticationService.credentials
            hasAppleIdentifier = credentials?.appleIdentifier != nil
            emailAddress = credentials?.emailAddress ?? ""
        }
    }

    func toggleChangePassword() {
        if reduceMotion {
            isChangingPassword.toggle()
            errorMessage = nil
        } else {
            withAnimation(.easeInOut) {
                isChangingPassword.toggle()
                errorMessage = nil
            }
        }
    }

    func validatePasswordAndSubmit(completion: (() async -> Void)? = nil) {

        guard canSubmit else {
            errorMessage = "Please fill all password fields."
            return
        }

        guard newPassword == confirmPassword else {
            errorMessage = "New passwords do not match."
            return
        }

        guard newPassword.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }

        errorMessage = nil

        Task {
            await completion?()
        }
    }

    func saveAccountInfo() {
        Task {
            do {
                try await authenticationService.changeEmailAddress(newEmailAddress: emailAddress)
            } catch {
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }

    // MARK: Private

    @AppStorage(ValidDatabaseKeys.emailAddress.rawValue, store: UserDefaults(suiteName: "group.MomCare")) private var emailAddress: String = ""

    @EnvironmentObject private var authenticationService: AuthenticationService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isEditing = false
    @State private var isChangingPassword = false
    @State private var errorMessage: String?
    @State private var alertMessage: String?
    @State private var showAlert = false

    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""

    @State private var hasAppleIdentifier: Bool = false
    @State private var showAppleConnectSheet: Bool = false

    private func handleAppleSignIn(_ result: Result<ASAuthorization, any Error>) async throws {
        switch result {
        case let .success(auth):
            guard
                let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = credential.identityToken,
                let tokenString = String(data: tokenData, encoding: .utf8)
            else {
                alertMessage = "Failed to extract Apple Sign-In token."
                showAlert = true
                return
            }

            _ = try await authenticationService.appleLogin(idToken: tokenString, existingEmailAddress: emailAddress)

        case let .failure(error):
            alertMessage = "Apple Sign-In failed: \(error.localizedDescription)"
            showAlert = true
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

private extension ProfileAccountSecurityView {

    func editableRow(
        title: String,
        text: Binding<String>,
        keyboard: UIKeyboardType
    ) -> some View {

        HStack {

            Text(title)

            Spacer()

            if isEditing {

                TextField("", text: text)
                    .keyboardType(keyboard)
                    .multilineTextAlignment(.trailing)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

            } else {

                Text(text.wrappedValue.isEmpty ? "Not Set" : text.wrappedValue)
                    .foregroundColor(.secondary)
            }
        }
    }
}
