import AVFoundation
import Combine
import CoreLocation
import EventKit
import HealthKit
import SwiftUI
import UserNotifications

struct PermissionsStatusView: View {
    // MARK: Internal

    var body: some View {
        List {
            Section("Media") {
                PermissionRow(label: "Camera", status: inspector.camera)
                PermissionRow(label: "Microphone", status: inspector.microphone)
            }
            Section("Communication") {
                PermissionRow(label: "Notifications", status: inspector.notifications)
            }
            Section("Location") {
                PermissionRow(label: "Location", status: inspector.location)
            }
            Section("Data") {
                PermissionRow(label: "Calendar", status: inspector.calendar)
                PermissionRow(label: "HealthKit", status: inspector.healthKit)
            }
            Section {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Open App Settings", systemImage: "gear")
                }
            }
        }
        .navigationTitle("Permissions")
        .navigationBarTitleDisplayMode(.inline)
        .task { await inspector.checkAll() }
    }

    // MARK: Private

    @StateObject private var inspector: PermissionsInspector = .init()
}

enum PermissionStatus {
    case authorized
    case denied
    case restricted
    case notDetermined
    case unknown

    // MARK: Internal

    var label: String {
        switch self {
        case .authorized: "Authorized"
        case .denied: "Denied"
        case .restricted: "Restricted"
        case .notDetermined: "Not Asked"
        case .unknown: "Unknown"
        }
    }

    var color: Color {
        switch self {
        case .authorized: .green
        case .denied: .red
        case .restricted: .orange
        case .notDetermined: .secondary
        case .unknown: .gray
        }
    }

    var icon: String {
        switch self {
        case .authorized: "checkmark.circle.fill"
        case .denied: "xmark.circle.fill"
        case .restricted: "minus.circle.fill"
        case .notDetermined: "questionmark.circle"
        case .unknown: "circle.dashed"
        }
    }
}

@MainActor
final class PermissionsInspector: ObservableObject {
    // MARK: Internal

    @Published var camera: PermissionStatus = .unknown
    @Published var microphone: PermissionStatus = .unknown
    @Published var notifications: PermissionStatus = .unknown
    @Published var location: PermissionStatus = .unknown
    @Published var calendar: PermissionStatus = .unknown
    @Published var healthKit: PermissionStatus = .unknown

    func checkAll() async {
        camera = cameraStatus()
        microphone = micStatus()
        notifications = await notificationStatus()
        location = locationStatus()
        calendar = calendarStatus()
        healthKit = healthKitStatus()
    }

    // MARK: Private

    private let locationManager: CLLocationManager = .init()

    private func cameraStatus() -> PermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: return .authorized
        case .denied: return .denied
        case .restricted: return .restricted
        case .notDetermined: return .notDetermined
        @unknown default: return .unknown
        }
    }

    private func micStatus() -> PermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized: return .authorized
        case .denied: return .denied
        case .restricted: return .restricted
        case .notDetermined: return .notDetermined
        @unknown default: return .unknown
        }
    }

    private func notificationStatus() async -> PermissionStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .ephemeral, .provisional: return .authorized
        case .denied: return .denied
        case .notDetermined: return .notDetermined
        @unknown default: return .unknown
        }
    }

    private func locationStatus() -> PermissionStatus {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse: return .authorized
        case .denied: return .denied
        case .restricted: return .restricted
        case .notDetermined: return .notDetermined
        @unknown default: return .unknown
        }
    }

    private func calendarStatus() -> PermissionStatus {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .fullAccess, .writeOnly: return .authorized
        case .denied: return .denied
        case .restricted: return .restricted
        case .notDetermined: return .notDetermined
        @unknown default: return .unknown
        }
    }

    private func healthKitStatus() -> PermissionStatus {
        guard HKHealthStore.isHealthDataAvailable() else {
            return .restricted
        }

        return .notDetermined
    }
}

private struct PermissionRow: View {
    let label: String
    let status: PermissionStatus

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Label(status.label, systemImage: status.icon)
                .font(.subheadline)
                .foregroundStyle(status.color)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(status.label)")
    }
}
