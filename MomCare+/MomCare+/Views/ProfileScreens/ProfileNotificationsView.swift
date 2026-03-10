import SwiftUI
import UserNotifications

struct ProfileNotificationsView: View {

    // MARK: Internal

    var body: some View {
        List {
            Section {
                Toggle("Enable Notifications", isOn: $isEnabled)
                    .onChange(of: isEnabled) { _, value in
                        handleToggle(value)
                    }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadStatus() }
    }

    // MARK: Private

    @State private var isEnabled = false

}

private extension ProfileNotificationsView {
    func loadStatus() {}

    func handleToggle(_ value: Bool) {
        if value {
            isEnabled = value

        } else {}
    }
}
