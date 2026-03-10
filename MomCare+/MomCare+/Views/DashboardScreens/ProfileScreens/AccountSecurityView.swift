import SwiftUI

struct AccountSecurityView: View {

    // MARK: Internal

    var body: some View {
        List {
            Section("Account Information") {
                infoRow(title: "Email", value: database[.emailAddress] as String? ?? "Not Set")
                infoRow(title: "Phone Number", value: authenticationService.userModel?.phoneNumber ?? "Not Set")
            }

            Section("Security") {
                Button(action: accountSecurityViewModel.toggleChangePassword) {
                    HStack {
                        Text("Change Password")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.primary)

                if accountSecurityViewModel.isChangingPassword {
                    SecureFieldRow(title: "Old Password", text: $accountSecurityViewModel.oldPassword)
                    SecureFieldRow(title: "New Password", text: $accountSecurityViewModel.newPassword)
                    SecureFieldRow(title: "Confirm Password", text: $accountSecurityViewModel.confirmPassword)

                    if let error = accountSecurityViewModel.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.vertical, 4)
                    }

                    Button("Change") {
                        accountSecurityViewModel.validateAndSubmit()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(accountSecurityViewModel.canSubmit ? Color("primaryAppColor") : .secondary)
                    .disabled(!accountSecurityViewModel.canSubmit)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Account & Security")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Private

    @EnvironmentObject private var authenticationService: AuthenticationService
    @StateObject private var accountSecurityViewModel: AccountSecurityViewModel = .init()

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

private extension AccountSecurityView {
    func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    AccountSecurityView()
}
