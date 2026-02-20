

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
        }
        .navigationTitle("About MomCare+")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.insetGrouped)
    }

    // MARK: Private

    private let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"

}

#Preview {
    AboutMomCareView()
}
