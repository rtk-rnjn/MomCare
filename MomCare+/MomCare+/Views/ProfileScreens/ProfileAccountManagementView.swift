import SwiftUI

struct ProfileAccountManagementView: View {

    // MARK: Internal

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Delete Account")

                    Spacer()

                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Text("Delete")
                    }
                }
            } footer: {
                Text("Deleting your account will permanently remove all your data from MomCare+. This action cannot be undone.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Account Management")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Account?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                Task {
                    await deleteAccount()
                }
            }

            Button(role: .cancel) {}

        } message: {
            Text("Are you sure you want to permanently delete your MomCare+ account and all associated data?")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "An unexpected error occurred.")
        }
    }

    // MARK: Private

    @State private var showDeleteAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage: String?
    @EnvironmentObject private var authenticationService: AuthenticationService

    private func deleteAccount() async {
        do {
            _ = try await authenticationService.delete()
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
}
