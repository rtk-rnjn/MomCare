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
                NavigationLink(destination: DebugMenuView()) {
                    Text("Debug Options")
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
    }

    // MARK: Private

    private let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Failed to fetch app version"

}
