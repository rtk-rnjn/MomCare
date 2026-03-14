import SwiftUI
import UserNotifications

struct NotificationTesterView: View {

    // MARK: Internal

    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: permissionIcon)
                        .foregroundStyle(permissionColor)
                    VStack(alignment: .leading) {
                        Text("Notification Permission")
                            .font(.subheadline.bold())
                        Text(permissionLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if permissionStatus == .notDetermined {
                        Button("Request") { requestPermission() }
                            .font(.caption.bold())
                    }
                }
            }

            // MARK: Delay Picker
            Section {
                HStack {
                    Label("Fire Delay", systemImage: "clock")
                    Spacer()
                    Text("\(Int(delaySeconds))s")
                        .foregroundStyle(.secondary)
                }
                Slider(value: $delaySeconds, in: 1...30, step: 1)
            } header: {
                Text("Configuration")
            }

            // MARK: Trigger Buttons
            Section("Trigger Notifications") {
                NotifButton(
                    label: "Test Notification",
                    icon: "bell.fill",
                    tint: .blue,
                    isEnabled: permissionStatus == .authorized
                ) { triggerTest() }

                NotifButton(
                    label: "Reminder Notification",
                    icon: "alarm.fill",
                    tint: .orange,
                    isEnabled: permissionStatus == .authorized
                ) { triggerReminder() }

                NotifButton(
                    label: "Scheduled Notification",
                    icon: "calendar.badge.clock",
                    tint: .purple,
                    isEnabled: permissionStatus == .authorized
                ) { triggerScheduled() }
            }

            // MARK: Pending
            Section {
                Button {
                    Task { await checkPending() }
                } label: {
                    Label("Check Pending", systemImage: "list.bullet.clipboard")
                }
                Button(role: .destructive) {
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    lastTriggered = "All pending cleared"
                } label: {
                    Label("Clear All Pending", systemImage: "trash")
                }
            }

            if let last = lastTriggered {
                Section("Last Action") {
                    Text(last)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Notification Tester")
        .navigationBarTitleDisplayMode(.inline)
        .task { await checkPermission() }
    }

    // MARK: Private

    @State private var permissionStatus: UNAuthorizationStatus = .notDetermined
    @State private var lastTriggered: String?
    @State private var delaySeconds: Double = 3

    private var permissionIcon: String {
        switch permissionStatus {
        case .authorized: return "bell.badge.fill"
        case .denied: return "bell.slash.fill"
        default: return "bell.fill"
        }
    }

    private var permissionColor: Color {
        switch permissionStatus {
        case .authorized: return .green
        case .denied: return .red
        default: return .secondary
        }
    }

    private var permissionLabel: String {
        switch permissionStatus {
        case .authorized: return "Authorized — notifications enabled"
        case .denied: return "Denied — go to Settings to enable"
        case .provisional: return "Provisional"
        case .notDetermined: return "Not yet requested"
        default: return "Unknown"
        }
    }

    private func checkPermission() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        permissionStatus = settings.authorizationStatus
    }

    private func requestPermission() {
        Task {
            let granted = try? await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            await checkPermission()
            lastTriggered = granted == true ? "Permission granted ✓" : "Permission denied ✗"
        }
    }

    private func triggerTest() {
        schedule(
            id: "debug.test",
            title: "🛠 Debug: Test",
            body: "This is a test notification from the debug menu.",
            delay: delaySeconds
        )
    }

    private func triggerReminder() {
        schedule(
            id: "debug.reminder",
            title: "⏰ Debug: Reminder",
            body: "Hey! This is your debug reminder notification.",
            delay: delaySeconds
        )
    }

    private func triggerScheduled() {
        schedule(
            id: "debug.scheduled",
            title: "📅 Debug: Scheduled",
            body: "This notification was scheduled via the debug menu.",
            delay: delaySeconds
        )
    }

    private func schedule(id: String, title: String, body: String, delay: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let req = UNNotificationRequest(identifier: "\(id).\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req) { err in
            DispatchQueue.main.async {
                if let err {
                    lastTriggered = "Error: \(err.localizedDescription)"
                } else {
                    lastTriggered = "\(title) scheduled in \(Int(delay))s"
                }
            }
        }
    }

    private func checkPending() async {
        let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        lastTriggered = "\(pending.count) pending request(s)"
    }
}

private struct NotifButton: View {
    let label: String
    let icon: String
    let tint: Color
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(label, systemImage: icon)
                .foregroundStyle(isEnabled ? tint : .secondary)
        }
        .disabled(!isEnabled)
    }
}
