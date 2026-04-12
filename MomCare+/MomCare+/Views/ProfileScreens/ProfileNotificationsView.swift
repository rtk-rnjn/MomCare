import SwiftUI
import UserNotifications

enum NotificationKey {
    static let globallyEnabled = "notifications.globallyEnabled"
    static let remoteEnabled = "notifications.remoteEnabled"
}

struct ProfileNotificationsView: View {
    // MARK: Internal

    var body: some View {
        List {
            Section {
                Toggle("Enable Notifications", isOn: globalToggleBinding)

                if globallyEnabled {
                    Toggle("Promotional Notifications", isOn: remoteToggleBinding)
                        .transition(transition)
                }
            }
        }
        .onChange(of: UIApplication.shared.isRegisteredForRemoteNotifications) {
            if UIApplication.shared.isRegisteredForRemoteNotifications == false {
                Task {
                    await unRegister()
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .animation(animation, value: globallyEnabled)
        .alert("Notifications Disabled", isPresented: $showSettingsAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.canOpenURL(url)
                }
            }
            Button("Cancel", role: .cancel) {
                globallyEnabled = false
            }
        } message: {
            Text("Please enable notifications in Settings to receive reminders.")
        }
    }

    // MARK: Private

    @AppStorage(NotificationKey.globallyEnabled, store: Database.shared.userDefaults) private var globallyEnabled = false
    @AppStorage(NotificationKey.remoteEnabled, store: Database.shared.userDefaults) private var remoteEnabled = false

    @State private var showSettingsAlert = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var animation: Animation? {
        reduceMotion ? nil : .smooth(duration: 0.3)
    }

    private var transition: AnyTransition {
        unsafe reduceMotion
            ? .opacity
            : .asymmetric(
                insertion: .push(from: .bottom).combined(with: .opacity),
                removal: .push(from: .top).combined(with: .opacity)
            )
    }

    private var globalToggleBinding: Binding<Bool> {
        Binding(
            get: { globallyEnabled },
            set: { enabled in
                Task {
                    if enabled {
                        let granted = await requestAuthorizationIfNeeded()
                        if granted {
                            globallyEnabled = true
                        } else {
                            let status = await currentAuthorizationStatus()
                            if status == .denied {
                                showSettingsAlert = true
                            }
                            globallyEnabled = false
                        }
                    } else {
                        globallyEnabled = false
                        remoteEnabled = false
                        UIApplication.shared.unregisterForRemoteNotifications()
                    }
                }
            }
        )
    }

    private var remoteToggleBinding: Binding<Bool> {
        Binding(
            get: { remoteEnabled },
            set: { enabled in
                remoteEnabled = enabled
                if enabled {
                    UIApplication.shared.registerForRemoteNotifications()
                } else {
                    UIApplication.shared.unregisterForRemoteNotifications()
                }
            }
        )
    }

    private func requestAuthorizationIfNeeded() async -> Bool {
        let currentStatus = await currentAuthorizationStatus()
        if currentStatus == .notDetermined {
            do {
                return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            } catch {
                return false
            }
        } else {
            return currentStatus == .authorized || currentStatus == .provisional
        }
    }

    private func currentAuthorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    private func unRegister() async {
        let _: NetworkResponse<Bool>? = try? await MCNetworkManager.shared.delete(url: Endpoint.apns.urlString, headers: MCAuthenticationService.authorizationHeaders)
    }
}

/// Shared preview card used by both meal and exercise detail views.
private struct NotificationPreviewSection: View {
    // MARK: Internal

    let title: String
    let description: String
    let icon: String
    let color: Color

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundStyle(color)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                reduceTransparency
                    ? Color(.systemGray5)
                    : Color(.systemBackground).opacity(0.001) // keeps tap area without visual change
            )
        } header: {
            Text("Preview")
        } footer: {
            Text("This is how the notification will appear on your device.")
        }
    }

    // MARK: Private

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
}
