import SwiftUI

struct DebugMenuView: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(DebugSection.allCases) { section in
                    NavigationLink(destination: section.destination()) {
                        Text(section.title)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle("Debug Menu")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

enum DebugSection: String, CaseIterable, Identifiable {
    case deviceInfo = "Device & App Info"
    case accessibility = "Accessibility Inspector"
    case featureFlags = "Feature Flags"
    case osLogs = "OS Logs"
    case permissions = "Permissions Status"
    case dataInspector = "Data Inspector"
    case notifications = "Notification Tester"
    case crashSimulator = "Crash Simulator"

    // MARK: Internal

    var id: String {
        rawValue
    }

    var title: String {
        rawValue
    }

    @ViewBuilder
    func destination() -> some View {
        switch self {
        case .deviceInfo: DeviceInfoView()
        case .accessibility: AccessibilityInspectorView()
        case .featureFlags: FeatureFlagsView()
        case .osLogs: OSLogsView()
        case .permissions: PermissionsStatusView()
        case .dataInspector: DataInspectorView()
        case .notifications: NotificationTesterView()
        case .crashSimulator: CrashSimulatorView()
        }
    }
}
