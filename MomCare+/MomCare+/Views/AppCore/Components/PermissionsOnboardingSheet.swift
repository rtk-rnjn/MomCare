import SwiftUI
import HealthKit
import EventKit
import UIKit

private let kFirstTime = "momcare_firsttime"

struct HealthKitError: LocalizedError {
    var errorDescription: String? { "HealthKit Access Denied" }
    var failureReason: String? { "The app does not have permission to access HealthKit data." }
    var recoverySuggestion: String? { "Please grant HealthKit permissions in Settings to enable health-related features." }
}

struct EKEventError: LocalizedError {
    var errorDescription: String? { "Calendar Access Denied" }
    var failureReason: String? { "The app does not have permission to access Calendar data." }
    var recoverySuggestion: String? { "Please grant Calendar permissions in Settings to enable calendar-related features." }
}

struct EKReminderError: LocalizedError {
    var errorDescription: String? { "Reminder Access Denied" }
    var failureReason: String? { "The app does not have permission to access Reminder data." }
    var recoverySuggestion: String? { "Please grant Reminder permissions in Settings to enable reminder-related features." }
}

private struct AppPermission: Identifiable {
    enum PermissionType {
        case healthKit
        case calendar
        case reminders
    }

    let id: UUID = .init()
    let icon: String
    let iconColor: Color
    let title: String
    let reason: String
    var isEnabled: Bool = false
    var isRequesting: Bool = false
    let type: PermissionType
}

struct PermissionsOnboardingSheetModifier: ViewModifier {

    // MARK: Internal

    @Binding var fetchingDataFromServer: Bool

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $firstTime) {
                firstTime = false
            } content: {
                PermissionsOnboardingSheet(
                    fetchingDataFromServer: $fetchingDataFromServer,
                    firstTime: $firstTime
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled()
            }
    }

    // MARK: Private

    @AppStorage(kFirstTime) private var firstTime: Bool = true

}

extension View {
    func permissionsOnboardingSheet(fetchingData: Binding<Bool>) -> some View {
        modifier(PermissionsOnboardingSheetModifier(fetchingDataFromServer: fetchingData))
    }
}

struct PermissionsOnboardingSheet: View {

    // MARK: Internal

    @Binding var fetchingDataFromServer: Bool
    @Binding var firstTime: Bool

    var body: some View {
        ZStack {
            (reduceTransparency ? Color(.systemBackground) : Color(MomCareAccent.secondary))
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                    .padding(.top, 48)
                    .padding(.horizontal, 28)
                    .accessibilitySortPriority(3)

                Divider()
                    .padding(.top, 32)
                    .padding(.horizontal, 28)

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach($permissions) { $permission in
                            PermissionRow(permission: $permission)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .accessibilitySortPriority(2)

                Divider()
                    .padding(.horizontal, 28)

                footerSection
                    .padding(.horizontal, 28)
                    .padding(.bottom, 36)
                    .padding(.top, 20)
                    .accessibilitySortPriority(1)
            }
        }
        .onAppear {
            if reduceMotion {
                hasAppeared = true
            } else {
                withAnimation(.easeOut(duration: 0.45)) {
                    hasAppeared = true
                }
            }
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    @State private var permissions: [AppPermission] = [
        AppPermission(
            icon: "figure.walk",
            iconColor: .green,
            title: "Health & Activity",
            reason: "Your step count and activity data help us tailor your weekly fitness plan and track recovery progress accurately.",
            type: .healthKit
        ),
        AppPermission(
            icon: "calendar",
            iconColor: .blue,
            title: "Calendar",
            reason: "We sync your appointments and check-ups directly into your calendar so nothing falls through the cracks.",
            type: .calendar
        ),
        AppPermission(
            icon: "checklist",
            iconColor: .orange,
            title: "Reminders",
            reason: "We'll nudge you gently — medication, hydration, prenatal vitamins — so your routine stays effortless.",
            type: .reminders
        )
    ]

    @State private var hasAppeared = false

    private var allPermissionsGranted: Bool {
        permissions.allSatisfy { $0.isEnabled }
    }

    private var isAnyPermissionRequestInFlight: Bool {
        permissions.contains { $0.isRequesting }
    }

    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                if fetchingDataFromServer {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.secondary)
                        .accessibilityHidden(true)

                    Text("Downloading content from the server ...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .accessibilityHidden(true)

                    Text("Downloading content from the server ... Done!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(reduceTransparency ? Color(.secondarySystemBackground) : .secondaryApp, in: Capsule())
            .padding(.bottom, 20)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                fetchingDataFromServer
                ? Text("Downloading content from the server")
                : Text("Downloading content from the server complete")
            )

            Text("While we're getting everything ready —")
                .font(.largeTitle.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.primary)
                .lineSpacing(2)
                .minimumScaleFactor(0.85)
                .accessibilityAddTraits(.isHeader)

            Text("Grant MomCare a few permissions to personalise your meal plan, exercises, and daily insights the moment they're ready.")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 10)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : (reduceMotion ? 0 : 12))
    }

    private var footerSection: some View {
        VStack(spacing: 12) {
            Button {
                firstTime = false
                dismiss()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .padding(.vertical, 12)
                    .background(MomCareAccent.primary, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .foregroundStyle(.white)
                    .opacity((allPermissionsGranted && !isAnyPermissionRequestInFlight) ? 1 : 0.6)
            }
            .buttonStyle(.plain)
            .disabled(!allPermissionsGranted || isAnyPermissionRequestInFlight)
            .accessibilityLabel("Continue")
            .accessibilityHint("Continues after all permissions are enabled.")
            .accessibilityAddTraits(.isButton)

            Text("You can change these permissions any time in Settings → MomCare+")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .opacity(hasAppeared ? 1 : 0)
    }
}

private struct PermissionRow: View {

    // MARK: Internal

    @Binding var permission: AppPermission

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(permission.iconColor.opacity(reduceTransparency ? 0.24 : 0.12))
                        .frame(width: 44, height: 44)

                    Image(systemName: permission.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(permission.iconColor)
                        .accessibilityHidden(true)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(permission.title)
                        .font(.system(.body, design: .rounded, weight: .semibold))
                        .foregroundStyle(.primary)

                    Text(permission.reason)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())

                if permission.isRequesting {
                    ProgressView()
                        .controlSize(.small)
                        .frame(minWidth: 51, minHeight: 31)
                        .accessibilityLabel("Requesting \(permission.title) permission")
                } else {
                    Toggle("", isOn: $permission.isEnabled)
                        .labelsHidden()
                        .tint(permission.iconColor)
                        .disabled(permission.isEnabled || permission.isRequesting)
                        .accessibilityLabel(Text(permission.title))
                        .accessibilityValue(Text(permission.isEnabled ? "Enabled" : "Not enabled"))
                        .accessibilityHint(Text("Double tap to grant access for \(permission.title)."))
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
            .accessibilityElement(children: .combine)

            Divider()
                .padding(.leading, 66)
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: permission.isRequesting)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: permission.isEnabled)
        .onChange(of: permission.isEnabled) { _, newValue in
            guard newValue else { return }
            guard !permission.isRequesting else { return }

            permission.isRequesting = true

            Task { @MainActor in
                defer { permission.isRequesting = false }

                do {
                    switch permission.type {
                    case .healthKit:
                        _ = try await contentServiceHandler.requestHealthKitAccess()
                        do {
                            try await contentServiceHandler.startStepCountObservation()
                        } catch {
                            controlState.error = error
                        }

                    case .calendar:
                        let granted = try await eventKitHandler.requestAccess(for: .event)
                        permission.isEnabled = granted
                        if !granted { ekEventError = EKEventError() }

                    case .reminders:
                        let granted = try await eventKitHandler.requestAccess(for: .reminder)
                        permission.isEnabled = granted
                        if !granted { ekReminderError = EKReminderError() }
                    }
                } catch {
                    permission.isEnabled = false
                    switch permission.type {
                    case .healthKit:
                        healthKitError = error
                    case .calendar:
                        ekEventError = error
                    case .reminders:
                        ekReminderError = error
                    }
                }
            }
        }
        .errorAlert(error: $ekEventError) { _ in
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
            Button("Cancel", role: .cancel) {
                ekEventError = nil
            }
        }
        .errorAlert(error: $ekReminderError) { _ in
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
            Button("Cancel", role: .cancel) {
                ekReminderError = nil
            }
        }
        .errorAlert(error: $healthKitError) { _ in
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
            Button("Cancel", role: .cancel) {
                healthKitError = nil
            }
        }
    }

    // MARK: Private

    @Environment(\.openURL) private var openURL
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    @State private var ekEventError: (any Error)?
    @State private var ekReminderError: (any Error)?
    @State private var healthKitError: (any Error)?

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
    @EnvironmentObject private var eventKitHandler: EventKitHandler
    @EnvironmentObject private var controlState: ControlState

}
