import SwiftUI
import OSLog

struct AboutMomCareView: View {

    // MARK: Internal

    var body: some View {
        List {
            Section {
                NavigationLink(destination: AboutUsView()) {
                    Text("About Us")
                }

                HStack {
                    Text("App Version")
                    Spacer()
                    Text(appVersion)
                        .foregroundStyle(.secondary)
                }
                .onLongPressGesture(minimumDuration: 0.5) {
                    debugOptions.toggle()
                    HapticsHandler.impact(.medium)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("App version \(appVersion)")
            }

            Section {
                NavigationLink(destination: CreditsView()) {
                    Text("Credits")
                }

                NavigationLink(destination: OpenSourceView()) {
                    Text("Open Source")
                }
            }

            if debugOptions {
                Section {
                    NavigationLink(destination: DebugMenuView()) {
                        Text("Debug Options")
                    }
                } footer: {
                    Text("Debug options are intended for developers and testers to diagnose issues. Avoid using them unless you know what you're doing.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(reduceMotion ? nil : .spring(), value: debugOptions)
        .navigationTitle("About MomCare+")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.insetGrouped)
    }

    // MARK: Private

    @AppStorage("debugOptions", store: UserDefaults(suiteName: "group.MomCare")) private var debugOptions: Bool = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Failed to fetch app version"
}
