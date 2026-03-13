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
                }

                if showDebugOptions {
                    Button(role: .destructive) {
                        crashApp = true
                    } label: {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("Crash App")
                        }
                    }
                    .confirmationDialog("Are you sure? This is mainly for DEBUG purpose", isPresented: $crashApp, titleVisibility: .visible) {
                        Button("FUCKING DO IT", role: .destructive) {
                            fatalError("Crashed Intentionally")
                        }
                    }
                    .foregroundStyle(.red)

                    Button {
                        showLogs = true
                    } label: {
                        HStack {
                            Group {
                                Image(systemName: "doc.text")
                                Text("View OS Logs")
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } footer: {
                Text("The debug options are meant for developers and testers to diagnose issues. Please avoid using them unless you know what you're doing.")
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
