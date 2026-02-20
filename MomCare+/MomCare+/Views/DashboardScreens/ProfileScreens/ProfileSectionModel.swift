

import Combine
import SwiftUI

struct ProfileSection {
    let title: String?
    let rows: [ProfileRow]
}

struct ProfileRow {
    let title: String
    let systemImage: String
    let type: ProfileRowType
}

final class AccountSecurityViewModel: ObservableObject {

    // MARK: Internal

    @Published var isChangingPassword: Bool = false
    @Published var errorMessage: String? = nil

    @Published var oldPassword = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""

    var canSubmit: Bool {
        !oldPassword.isEmpty &&
            !newPassword.isEmpty &&
            !confirmPassword.isEmpty
    }

    func toggleChangePassword() {
        withAnimation(.easeInOut) {
            isChangingPassword.toggle()
            errorMessage = nil
        }
    }

    func validateAndSubmit() {
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
        submitChange()
    }

    // MARK: Private

    private func submitChange() {
        print("Password changed")

        oldPassword = ""
        newPassword = ""
        confirmPassword = ""
        isChangingPassword = false
    }
}
