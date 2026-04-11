import SwiftUI

struct DebugMenuView: View {
    var body: some View {
        List {
            ForEach(DebugSection.allCases) { section in
                NavigationLink {
                    switch section {
                    case .deviceInfo: DeviceInfoView()
                    case .accessibility: AccessibilityInspectorView()
                    case .featureFlags: FeatureFlagsView()
                    case .osLogs: OSLogsView()
                    case .permissions: PermissionsStatusView()
                    case .dataInspector: DataInspectorView()
                    case .notifications: NotificationTesterView()
                    case .crashSimulator: CrashSimulatorView()
                    }
                } label: {
                    Label {
                        Text(section.title)
                    } icon: {
                        switch section {
                        case .deviceInfo: Image(systemName: "iphone")
                        case .accessibility: Image(systemName: "figure.wave.circle")
                        case .featureFlags: Image(systemName: "flag")
                        case .osLogs: Image(systemName: "terminal")
                        case .permissions: Image(systemName: "hand.raised.slash")
                        case .dataInspector: Image(systemName: "eye")
                        case .notifications: Image(systemName: "bell")
                        case .crashSimulator: Image(systemName: "exclamationmark.triangle")
                        }
                    }

                }

            }
        }
        .navigationTitle("Debug Menu")
        .navigationBarTitleDisplayMode(.inline)
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
}
