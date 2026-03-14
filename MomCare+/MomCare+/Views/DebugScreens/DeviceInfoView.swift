import SwiftUI
import UIKit
import Combine

struct DeviceInfoView: View {

    // MARK: Internal

    var body: some View {
        List {
            Section("Application") {
                DebugRow(label: "Version", value: appVersion)
                DebugRow(label: "Build", value: buildNumber)
                DebugRow(label: "Bundle ID", value: bundleID)
                DebugRow(label: "Environment", value: environment, valueColor: envColor)
                DebugRow(label: "Launch Count", value: "\(launchCount)")
                DebugRow(label: "App Uptime", value: formattedUptime(uptime))
            }

            Section("Device") {
                DebugRow(label: "Model", value: deviceModel)
                DebugRow(label: "System Version", value: systemVersion)
                DebugRow(label: "Identifier", value: deviceIdentifier)
                DebugRow(label: "Screen Size", value: screenSize)
                DebugRow(label: "Screen Scale", value: "\(Int(UIScreen.current.scale))×")
            }

            Section("Storage") {
                DebugRow(label: "Disk Usage", value: diskUsage)
                DebugRow(label: "Free Space", value: freeDisk)
            }
        }
        .navigationTitle("Device & App Info")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in
            uptime = ProcessInfo.processInfo.systemUptime
        }
    }

    // MARK: Private

    @State private var uptime: TimeInterval = ProcessInfo.processInfo.systemUptime

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
    }

    private var bundleID: String {
        Bundle.main.bundleIdentifier ?? "N/A"
    }

    private var environment: String {
        #if DEBUG
        return "Development"
        #elseif TESTFLIGHT
        return "TestFlight / Staging"
        #else
        return "Production"
        #endif
    }

    private var envColor: Color {
        switch environment {
        case "Development": return .orange
        case "TestFlight / Staging": return .yellow
        default: return .green
        }
    }

    private var launchCount: Int {
        let count = UserDefaults.standard.integer(forKey: "debug_launch_count") + 1
        UserDefaults.standard.set(count, forKey: "debug_launch_count")
        return count
    }

    private var deviceModel: String {
        UIDevice.current.model
    }

    private var systemVersion: String {
        "iOS \(UIDevice.current.systemVersion)"
    }

    private var deviceIdentifier: String {
        UIDevice.current.identifierForVendor?.uuidString ?? "N/A"
    }

    private var screenSize: String {
        let s = UIScreen.current.bounds.size
        return "\(Int(s.width)) × \(Int(s.height)) pt"
    }

    private var diskUsage: String {
        guard let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
              let total = attrs[.systemSize] as? Int64,
              let free = attrs[.systemFreeSize] as? Int64 else { return "N/A" }

        let usedGB = Double(total - free) / 1_000_000_000

        return "\(Measurement(value: usedGB, unit: UnitInformationStorage.gigabytes).formatted(.measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(1))))) used"
    }

    private var freeDisk: String {
        guard let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
              let free = attrs[.systemFreeSize] as? Int64 else { return "N/A" }

        let freeSpace = Measurement(value: Double(free), unit: UnitInformationStorage.bytes)
            .converted(to: .gigabytes)

        return "\(freeSpace.formatted(.measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(1))))) free"
    }

    private func formattedUptime(_ t: TimeInterval) -> String {
        Duration.seconds(t).formatted(.time(pattern: .hourMinuteSecond))
    }
}
