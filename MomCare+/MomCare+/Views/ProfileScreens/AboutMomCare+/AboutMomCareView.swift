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
            }

            Section {
                NavigationLink(destination: CreditsView()) {
                    Text("Credits")
                }

                NavigationLink(destination: OpenSourceView()) {
                    Text("Open Source")
                }
            }

            Section {
                HStack {
                    Text("Enable Debug Options")
                    Spacer()
                    Toggle("", isOn: $showDebugOptions)
                        .labelsHidden()
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Enable debug options")
                .accessibilityValue(showDebugOptions ? "On" : "Off")
                .accessibilityHint("Toggles visibility of developer debugging tools")

                if showDebugOptions {
                    Button(role: .destructive) {
                        crashApp = true
                    } label: {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .accessibilityHidden(true)
                            Text("Crash App")
                        }
                    }
                    .confirmationDialog("Are you sure? This is intended for debug purposes only.", isPresented: $crashApp, titleVisibility: .visible) {
                        Button("Crash App", role: .destructive) {
                            fatalError("Crashed intentionally")
                        }
                    }
                    .foregroundStyle(.red)
                    .accessibilityLabel("Crash App")
                    .accessibilityHint("Immediately terminates the app for testing crash reporting")

                    Button {
                        showLogs = true
                    } label: {
                        HStack {
                            Group {
                                Image(systemName: "doc.text")
                                    .accessibilityHidden(true)
                                Text("View OS Logs")
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                                .accessibilityHidden(true)
                        }
                    }
                    .accessibilityLabel("View OS Logs")
                    .accessibilityHint("Opens a viewer showing recent OS log entries")
                    .accessibilityAddTraits(.isButton)
                }
            } footer: {
                Text("Debug options are intended for developers and testers to diagnose issues. Avoid using them unless you know what you're doing.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

        }
        .navigationTitle("About MomCare+")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.insetGrouped)
        .navigationDestination(isPresented: $showLogs) {
            OSLogsView()
        }
    }

    // MARK: Private

    @AppStorage("showDebugOptions", store: UserDefaults(suiteName: "group.MomCare")) private var showDebugOptions: Bool = false

    @State private var crashApp: Bool = false
    @State private var showLogs: Bool = false

    private let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Failed to fetch app version"

}
