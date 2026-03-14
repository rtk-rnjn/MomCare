import SwiftUI

struct DebugMenuView: View {

    // MARK: Internal

    var body: some View {
        NavigationStack {
            List {
                ForEach(DebugSection.allCases) { section in
                    NavigationLink(destination: section.destination(store: store)) {
                        Text(section.title)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle("Debug Menu")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: Private

    @EnvironmentObject private var store: DebugMenuStore

}

enum DebugSection: String, CaseIterable, Identifiable {
    case deviceInfo = "Device & App Info"
    case accessibility = "Accessibility Inspector"
    case performance = "Performance Monitor"
    case featureFlags = "Feature Flags"
    case network = "Network Inspector"
    case logs = "Console Logs"
    case osLogs = "OS Logs"
    case permissions = "Permissions Status"
    case dataInspector = "Data Inspector"
    case notifications = "Notification Tester"
    case crashSimulator = "Crash Simulator"

    // MARK: Internal

    var id: String { rawValue }
    var title: String { rawValue }

    @ViewBuilder // swiftlint:disable:next cyclomatic_complexity
    func destination(store: DebugMenuStore) -> some View {
        switch self {
        case .deviceInfo: DeviceInfoView()
        case .accessibility: AccessibilityInspectorView()
        case .performance: PerformanceMonitorView()
        case .featureFlags: FeatureFlagsView()
        case .network: NetworkInspectorView()
        case .logs: LogsConsoleView()
        case .osLogs: OSLogsView()
        case .permissions: PermissionsStatusView()
        case .dataInspector: DataInspectorView()
        case .notifications: NotificationTesterView()
        case .crashSimulator: CrashSimulatorView()
        }
    }
}
