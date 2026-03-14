import SwiftUI

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
                Text("Changing your email address will force logout on all devices. You will need to log in again with the new email address.")
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
                            .contentTransition(.symbolEffect)
                            .animation(
                                reduceMotion ? nil : .spring(response: 0.25, dampingFraction: 0.8),
                                value: isChangingPassword
                            )
                    }
                }
                .foregroundColor(.primary)

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
                Text("Changing your password will force logout on all devices. You will need to log in again with the new password.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Account & Security")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "An unexpected error occurred.")
        }

        // Toolbar Button
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
            emailAddress = database[.emailAddress] as String? ?? ""
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

    private let database: Database = .init()
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

            } else {

                Text(text.wrappedValue.isEmpty ? "Not Set" : text.wrappedValue)
                    .foregroundColor(.secondary)
            }
        }
    }
}
