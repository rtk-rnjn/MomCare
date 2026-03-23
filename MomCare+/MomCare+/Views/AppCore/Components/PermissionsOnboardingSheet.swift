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
        ZStack(alignment: .bottom) {
            (reduceTransparency ? Color(.systemBackground) : Color(MomCareAccent.secondary))
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    serverStatusPill
                        .padding(.top, 36)
                        .padding(.horizontal, 24)

                    heroHeader
                        .padding(.top, 24)
                        .padding(.horizontal, 24)
                        .accessibilitySortPriority(2)

                    VStack(spacing: 12) {
                        ForEach($permissions) { $permission in
                            PermissionRow(permission: $permission)
                        }
                    }
                    .padding(.top, 28)
                    .padding(.horizontal, 20)
                    .accessibilitySortPriority(1)

                    Text("You can change these permissions anytime from the Settings tab.")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 20)

                    Spacer().frame(height: 100)
                }
            }

            continueButton
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

    private var allPermissionsGranted: Bool {
        permissions.allSatisfy { $0.isEnabled }
    }

    private var isAnyPermissionRequestInFlight: Bool {
        permissions.contains { $0.isRequesting }
    }

    // MARK: Subviews

    private var serverStatusPill: some View {
        HStack(spacing: 8) {
            if fetchingDataFromServer {
                ProgressView()
                    .scaleEffect(0.75)
                    .tint(.secondary)
                    .accessibilityHidden(true)
                Text("Downloading content…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .accessibilityHidden(true)
                Text("Content ready!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            reduceTransparency
                ? Color(.secondarySystemBackground)
                : Color(.secondarySystemBackground).opacity(0.7),
            in: Capsule()
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            fetchingDataFromServer
                ? "Downloading content from the server"
                : "Content downloaded and ready"
        )
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("While we're getting\neverything ready —")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.primary)
                .lineSpacing(2)
                .minimumScaleFactor(0.85)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Text("Grant MomCare a few permissions to personalise your meal plan, exercises, and daily insights the moment they're ready.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var continueButton: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [
                    Color(reduceTransparency ? .secondary : MomCareAccent.secondary).opacity(0),
                    Color(reduceTransparency ? .secondary : MomCareAccent.secondary)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 32)
            .allowsHitTesting(false)

            Button {
                firstTime = false
                dismiss()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        MomCareAccent.primary.opacity(
                            (allPermissionsGranted && !isAnyPermissionRequestInFlight) ? 1 : 0.35
                        ),
                        in: RoundedRectangle(cornerRadius: 24, style: .continuous)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            .buttonStyle(.plain)
            .disabled(!allPermissionsGranted || isAnyPermissionRequestInFlight)
            .accessibilityLabel("Continue")
            .accessibilityHint("Continues after all permissions are enabled.")
            .background(
                Color(reduceTransparency ? .secondary : MomCareAccent.secondary)
            )
        }
    }
}

private struct PermissionRow: View {

    // MARK: Internal

    @Binding var permission: AppPermission

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(permission.iconColor.opacity(reduceTransparency ? 0.24 : 0.12))
                    .frame(width: 48, height: 48)

                Image(systemName: permission.icon)
                    .font(.body.weight(.medium))
                    .foregroundStyle(permission.iconColor)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(permission.title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(permission.reason)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Group {
                if permission.isRequesting {
                    ProgressView()
                        .controlSize(.small)
                        .frame(width: 51, height: 31)
                        .accessibilityLabel("Requesting \(permission.title) permission")
                } else {
                    Toggle("", isOn: $permission.isEnabled)
                        .labelsHidden()
                        .tint(permission.iconColor)
                        .disabled(permission.isEnabled || permission.isRequesting)
                        .accessibilityLabel(permission.title)
                        .accessibilityValue(permission.isEnabled ? "Enabled" : "Not enabled")
                        .accessibilityHint("Double tap to grant access for \(permission.title).")
                }
            }
            .padding(.top, 8)
        }
        .padding(16)
        .background(
            reduceTransparency
                ? Color(.secondarySystemBackground)
                : Color(.systemBackground).opacity(0.6),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .accessibilityElement(children: .combine)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: permission.isRequesting)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: permission.isEnabled)
        .onChange(of: permission.isEnabled) { _, newValue in
            guard newValue, !permission.isRequesting else { return }
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
                    case .healthKit: healthKitError = error
                    case .calendar: ekEventError = error
                    case .reminders: ekReminderError = error
                    }
                }
            }
        }
        .errorAlert(error: $ekEventError) { _ in
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
            }
            Button("Cancel", role: .cancel) { ekEventError = nil }
        }
        .errorAlert(error: $ekReminderError) { _ in
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
            }
            Button("Cancel", role: .cancel) { ekReminderError = nil }
        }
        .errorAlert(error: $healthKitError) { _ in
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
            }
            Button("Cancel", role: .cancel) { healthKitError = nil }
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
