// CrashSimulatorView.swift

import SwiftUI

struct CrashSimulatorView: View {

    // MARK: Internal

    var body: some View {
        List {
            Section {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("⚠️ Danger Zone")
                            .font(.subheadline.bold())
                        Text("Actions in this panel can terminate the app or alter system state. Use in development only.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                }
            }

            Section("Crash Simulation") {
                SimulatorRow(
                    label: "Force Crash",
                    description: "Calls fatalError() to simulate a crash.",
                    icon: "bolt.trianglebadge.exclamationmark.fill",
                    tint: .red
                ) { showCrashConfirm = true }

                SimulatorRow(
                    label: "Simulate Memory Warning",
                    description: "Posts UIApplicationDidReceiveMemoryWarning notification.",
                    icon: "memorychip.fill",
                    tint: .orange
                ) { showMemWarningConfirm = true }
            }

            Section("Network Simulation") {
                SimulatorRow(
                    label: "Simulate API Failure",
                    description: "Logs a mock 500 Internal Server Error entry to the network inspector.",
                    icon: "wifi.slash",
                    tint: .pink
                ) { showAPIFailureConfirm = true }
            }

            Section("UI Simulation") {
                SimulatorRow(
                    label: "Shake Device",
                    description: "Triggers UIKit's shake notification to invoke responder chain.",
                    icon: "iphone.radiowaves.left.and.right",
                    tint: .purple
                ) { simulateShake() }

                SimulatorRow(
                    label: "Post Background Transition",
                    description: "Notifies observers that the app moved to background.",
                    icon: "square.on.square.dashed",
                    tint: .indigo
                ) { simulateBackground() }
            }

            if let last = lastSimulation {
                Section("Last Simulation") {
                    Text(last)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Crash Simulator")
        .navigationBarTitleDisplayMode(.inline)

        // MARK: Confirmation Dialogs
        .confirmationDialog("Force Crash", isPresented: $showCrashConfirm, titleVisibility: .visible) {
            Button("Crash Now", role: .destructive) { fatalError("[DebugMenu] Intentional crash triggered.") }
        } message: {
            Text("This will immediately terminate the app.")
        }
        .confirmationDialog("Simulate Memory Warning", isPresented: $showMemWarningConfirm, titleVisibility: .visible) {
            Button("Send Warning", role: .destructive) { simulateMemoryWarning() }
        } message: {
            Text("This posts a memory warning to all active view controllers.")
        }
        .confirmationDialog("Simulate API Failure", isPresented: $showAPIFailureConfirm, titleVisibility: .visible) {
            Button("Simulate Failure", role: .destructive) { simulateAPIFailure() }
        }
    }

    // MARK: Private

    @State private var showCrashConfirm = false
    @State private var showAPIFailureConfirm = false
    @State private var showMemWarningConfirm = false
    @State private var lastSimulation: String?

    private func simulateMemoryWarning() {
        NotificationCenter.default.post(
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        lastSimulation = "[\(timestamp())] Memory warning posted"
    }

    private func simulateAPIFailure() {
        DebugLogger.shared.log(
            "SIMULATED: 500 Internal Server Error — GET /api/v1/feed",
            level: .error,
            category: .network
        )
        lastSimulation = "[\(timestamp())] API failure injected into Network Inspector"
    }

    private func simulateShake() {
        UIDevice.current.setValue(UIDeviceOrientation.faceDown.rawValue, forKey: "orientation")
        NotificationCenter.default.post(name: .init("UIDeviceOrientationDidChangeNotification"), object: nil)
        lastSimulation = "[\(timestamp())] Shake notification posted"
    }

    private func simulateBackground() {
        NotificationCenter.default.post(
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        lastSimulation = "[\(timestamp())] Background transition posted"
    }

    private func timestamp() -> String {
        Date().formatted(date: .omitted, time: .standard)
    }
}

// MARK: - Simulator Row

private struct SimulatorRow: View {
    let label: String
    let description: String
    let icon: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(tint.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.subheadline.bold())
                        .foregroundStyle(tint)
                }
                .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.subheadline.bold())
                        .foregroundStyle(tint)
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityHint(description)
    }
}
