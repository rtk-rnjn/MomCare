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
#if DEBUG
            Button("Crash App") {
                fatalError("This is a test crash for Crashlytics.")
            }
            .foregroundStyle(.red)
#endif // DEBUG
        }
        .navigationTitle("About MomCare+")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.insetGrouped)
    }

    // MARK: Private

    private let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Failed to fetch app version"

}

#Preview {
    AboutMomCareView()
}
