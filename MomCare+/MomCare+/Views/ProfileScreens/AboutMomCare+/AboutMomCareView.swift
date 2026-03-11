import SwiftUI

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

            Button("Crash App", role: .destructive) {
                crashApp = true
            }
            .confirmationDialog("Are you sure? This is mainly for DEBUG purpose", isPresented: $crashApp, titleVisibility: .visible) {
                Button("FUCKING DO IT", role: .destructive) {
                    fatalError("Crashed Intentionally")
                }
            }
            .foregroundStyle(.red)

        }
        .navigationTitle("About MomCare+")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.insetGrouped)
    }

    // MARK: Private

    @State private var crashApp: Bool = false

    private let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Failed to fetch app version"

}
