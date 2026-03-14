import SwiftUI

struct DebugMenuView: View {

    // MARK: Internal

    var body: some View {
        NavigationStack {
            List {
                ForEach(DebugSection.allCases) { section in
                    NavigationLink(destination: section.destination(store: store)) {
                        Label(section.title, systemImage: section.icon)
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
    case logs = "Logs Console"
    case osLogs = "OS Logs"
    case permissions = "Permissions Status"
    case dataInspector = "Data Inspector"
    case notifications = "Notification Tester"
    case crashSimulator = "Crash Simulator"

    // MARK: Internal

    var id: String { rawValue }
    var title: String { rawValue }

    var icon: String {
        switch self {
        case .deviceInfo: return "iphone"
        case .accessibility: return "accessibility"
        case .performance: return "gauge.with.dots.needle.67percent"
        case .featureFlags: return "flag.2.crossed"
        case .network: return "network"
        case .logs: return "text.alignleft"
        case .osLogs: return "rectangle.stack.fill"
        case .permissions: return "lock.shield"
        case .dataInspector: return "cylinder.split.1x2"
        case .notifications: return "bell.badge"
        case .crashSimulator: return "exclamationmark.triangle"
        }
    }

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

struct DebugMenuGestureModifier: ViewModifier {

    // MARK: Internal

    func body(content: Content) -> some View {
        content
            .onLongPressGesture(minimumDuration: 2.0) {
                isPresented = true
            }
            .sheet(isPresented: $isPresented) {
                DebugMenuView()
            }
    }

    // MARK: Private

    @State private var isPresented = false

}

extension View {
    func debugMenuGesture() -> some View {
        modifier(DebugMenuGestureModifier())
    }
}
