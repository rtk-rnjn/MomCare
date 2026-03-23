import SwiftUI
import HealthKit
import EventKit

private let kFirstTime = "momcare_firsttime"

struct HealthKitError: LocalizedError {

    var response: [HKQuantityTypeIdentifier: HKAuthorizationStatus] = [:]

    var errorDescription: String? { "HealthKit Access Denied" }

    var failureReason: String? {
        "The app does not have permission to access HealthKit data."
    }

    var recoverySuggestion: String? {
        "Please grant HealthKit permissions in your device settings to enable health-related features."
    }
}

struct EKEventError: LocalizedError {
    var errorDescription: String? { "Calendar Access Denied" }
    var failureReason: String? { "The app does not have permission to access Calendar data." }
    var recoverySuggestion: String? { "Please grant Calendar permissions in your device settings to enable calendar-related features." }
}

struct EKReminderError: LocalizedError {
    var errorDescription: String? { "Reminder Access Denied" }
    var failureReason: String? { "The app does not have permission to access Reminder data." }
    var recoverySuggestion: String? { "Please grant Reminder permissions in your device settings to enable reminder-related features." }
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
                PermissionsOnboardingSheet(fetchingDataFromServer: $fetchingDataFromServer, firstTime: $firstTime)
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
            Color(MomCareAccent.secondary)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                headerSection
                    .padding(.top, 48)
                    .padding(.horizontal, 28)

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

                Divider()
                    .padding(.horizontal, 28)

                footerSection
                    .padding(.horizontal, 28)
                    .padding(.bottom, 36)
                    .padding(.top, 20)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                hasAppeared = true
            }
        }
    }

    // MARK: Private

    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

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

    private var headerSection: some View {
        VStack(spacing: 0) {

            HStack(spacing: 8) {
                if fetchingDataFromServer {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.secondary)
                    Text("Downloading content from the server ...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Downloading content from the server ... Done!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(.quaternary, in: Capsule())
            .padding(.bottom, 20)

            Text("While we're getting everything ready —")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.primary)
                .lineSpacing(2)

            Text("Grant MomCare a few permissions to personalise your meal plan, exercises, and daily insights the moment they're ready.")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 10)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 12)
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: 12) {
            Button {
                firstTime = false
                dismiss()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(MomCareAccent.primary, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .disabled(!permissions.allSatisfy { $0.isEnabled })

            Text("You can change these permissions any time in Settings → MomCare+")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
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
                        .fill(permission.iconColor.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: permission.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(permission.iconColor)
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
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())

                // Toggle
                Toggle("", isOn: $permission.isEnabled)
                    .labelsHidden()
                    .tint(permission.iconColor)
                    .disabled(permission.isEnabled)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 8)

            Divider()
                .padding(.leading, 66)
        }
        .onChange(of: permission.isEnabled) { _, _ in
            Task {
                switch permission.type {
                case .healthKit:
                    do {
                        _ = try await contentServiceHandler.requestHealthKitAccess()
                    } catch {
                        healthKitError = HealthKitError()
                    }

                case .calendar:
                    do {
                        permission.isEnabled = try await eventKitHandler.requestAccess(for: .event)
                    } catch {
                        ekEventError = EKEventError()
                    }

                case .reminders:
                    do {
                        permission.isEnabled = try await eventKitHandler.requestAccess(for: .reminder)
                    } catch {
                        ekReminderError = EKReminderError()
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

            Button(role: .close) {
                ekEventError = nil
            }
        }
        .errorAlert(error: $ekReminderError) { _ in
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }

            Button(role: .close) {
                ekEventError = nil
            }
        }
        .errorAlert(error: $healthKitError) { _ in
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }

            Button(role: .close) {
                healthKitError = nil
            }
        }
    }

    // MARK: Private

    @Environment(\.openURL) private var openURL

    @State private var ekEventError: (any Error)?
    @State private var ekReminderError: (any Error)?
    @State private var healthKitError: (any Error)?

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
    @EnvironmentObject private var eventKitHandler: EventKitHandler

    @State private var isExpanded = true

}
