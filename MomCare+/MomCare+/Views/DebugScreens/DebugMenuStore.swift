import SwiftUI
import Combine
import Collections
import DequeModule

@MainActor
final class DebugMenuStore: ObservableObject {

    // MARK: Lifecycle

    init() {
        startPerformanceTimer()
        FPSMonitor.shared.start()
        FPSMonitor.shared.onFPSUpdate = { fps in
            DispatchQueue.main.async {
                self.performanceSnapshot.fps = fps
            }
        }
        DebugLogger.shared.onNewEntry = { entry in
            DispatchQueue.main.async {
                self.logEntries.insert(entry, at: 0)
                if (self.logEntries.count) > 500 {
                    self.logEntries = Array(self.logEntries.prefix(500))
                }
            }
        }
    }

    // MARK: Internal

    @Published var networkRequests: Deque<DebugNetworkRequest> = .init()
    @Published var logEntries: [DebugLogEntry] = []
    @Published var performanceSnapshot: PerformanceSnapshot = .init()

    @Published var cpuHistory: [PerformancePoint] = []
    @Published var ramHistory: [PerformancePoint] = []
    @Published var fpsHistory: [PerformancePoint] = []

    func addNetworkRequest(_ request: DebugNetworkRequest) {
        networkRequests.prepend(request)
        if networkRequests.count > 200 {
            _ = networkRequests.popLast()
        }
    }

    func clearNetworkRequests() { networkRequests = [] }
    func clearLogs() { logEntries = [] }

    // MARK: Private

    private let maxHistory = 60

    private var performanceTimer: AnyCancellable?

    private func startPerformanceTimer() {
        performanceTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                let snap = PerformanceSnapshot.capture()
                self.performanceSnapshot = snap

                let now = Date()
                func append(_ point: PerformancePoint, to arr: inout [PerformancePoint]) {
                    if arr.count >= self.maxHistory { arr.removeFirst() }
                    arr.append(point)
                }
                append(.init(time: now, value: snap.cpuUsage), to: &self.cpuHistory)
                append(.init(time: now, value: snap.ramUsageMB), to: &self.ramHistory)
                append(.init(time: now, value: snap.fps), to: &self.fpsHistory)
            }
    }

}

enum FeatureFlagState: String {
    case experimentalFeatures
    case debugLogging
    case forceDarkMode
    case forceLightMode
    case useMockAPIs
    case uiDebuggingOverlays
}

struct DebugNetworkRequest: Identifiable {
    let id: UUID = .init()
    let timestamp: Date = .init()
    let method: String
    let url: String
    let statusCode: Int?
    let responseTime: TimeInterval
    let requestBody: String?
    let responseBody: String?
    let error: String?

    var statusColor: Color {
        guard let code = statusCode else { return .gray }
        switch code {
        case 200..<300: return .green
        case 300..<400: return .red
        case 400..<500: return .red
        default: return .red
        }
    }
}

struct DebugLogEntry: Identifiable {
    enum LogLevel: String, CaseIterable {
        case verbose = "VERBOSE"
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"

        // MARK: Internal

        var color: Color {
            switch self {
            case .verbose: return .secondary
            case .debug: return .blue
            case .info: return .primary
            case .warning: return .yellow
            case .error: return .red
            }
        }

        var icon: String {
            switch self {
            case .verbose: return "circle"
            case .debug: return "ant"
            case .info: return "info.circle"
            case .warning: return "exclamationmark.triangle"
            case .error: return "xmark.octagon"
            }
        }
    }

    enum LogCategory: String, CaseIterable {
        case all = "All"
        case network = "Network"
        case ui = "UI"
        case error = "Errors"
        case data = "Data"

        // MARK: Internal

        var icon: String {
            switch self {
            case .all: return "list.bullet"
            case .network: return "network"
            case .ui: return "rectangle.on.rectangle"
            case .error: return "exclamationmark.circle"
            case .data: return "cylinder"
            }
        }
    }

    let id: UUID = .init()
    let timestamp: Date
    let level: LogLevel
    let category: LogCategory
    let message: String

}

struct PerformanceSnapshot {

    // MARK: Internal

    var cpuUsage: Double = 0
    var ramUsageMB: Double = 0
    var diskUsageGB: Double = 0
    var fps: Double = 60
    var networkSentKB: Double = 0
    var networkReceivedKB: Double = 0
    var backgroundTasks: Int = 0

    static func capture() -> PerformanceSnapshot {
        var snap = PerformanceSnapshot()
        snap.cpuUsage = Self.cpuUsage()
        snap.ramUsageMB = Self.ramUsage()
        snap.diskUsageGB = Self.diskUsage()
        snap.fps = 60
        return snap
    }

    // MARK: Private

    private static func cpuUsage() -> Double {
        var totalUsage: Double = 0
        var threadList: thread_act_array_t?
        var threadCount = mach_msg_type_number_t(0)
        let task = unsafe mach_task_self_
        guard unsafe task_threads(task, &threadList, &threadCount) == KERN_SUCCESS,
              let list = unsafe threadList else { return 0 }
        for i in 0..<Int(threadCount) {
            var info = thread_basic_info()
            var infoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
            let kr: kern_return_t = unsafe withUnsafeMutablePointer(to: &info) {
                unsafe $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    unsafe thread_info(list[i], thread_flavor_t(THREAD_BASIC_INFO), $0, &infoCount)
                }
            }
            if kr == KERN_SUCCESS {
                let threadInfo = info
                if threadInfo.flags & TH_FLAGS_IDLE == 0 {
                    totalUsage += Double(threadInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100
                }
            }
        }
        vm_deallocate(task, vm_address_t(bitPattern: list), vm_size_t(threadCount) * vm_size_t(MemoryLayout<thread_t>.stride))
        return min(totalUsage, 100)
    }

    private static func ramUsage() -> Double {
        var info = task_vm_info_data_t()
        var size = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size / MemoryLayout<natural_t>.size)
        let kr = unsafe withUnsafeMutablePointer(to: &info) {
            unsafe $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                unsafe task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &size)
            }
        }
        guard kr == KERN_SUCCESS else { return 0 }
        return Double(info.phys_footprint) / 1024 / 1024
    }

    private static func diskUsage() -> Double {
        guard let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
              let total = attrs[.systemSize] as? Int64,
              let free = attrs[.systemFreeSize] as? Int64 else { return 0 }
        return Double(total - free) / 1_000_000_000
    }
}

final class DebugLogger {

    // MARK: Lifecycle

    private init() {}

    // MARK: Internal

    static let shared: DebugLogger = .init()

    var onNewEntry: ((DebugLogEntry) -> Void)?

    func log(_ message: String,
             level: DebugLogEntry.LogLevel = .info,
             category: DebugLogEntry.LogCategory = .data) {
        let entry = DebugLogEntry(
            timestamp: Date(),
            level: level,
            category: category,
            message: message
        )

        onNewEntry?(entry)
    }
}
