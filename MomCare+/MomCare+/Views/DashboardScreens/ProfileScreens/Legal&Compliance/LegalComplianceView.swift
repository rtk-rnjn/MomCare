

import SwiftUI

struct LegalComplianceView: View {
    var body: some View {
        List {
            Section {
                NavigationLink("Privacy Policy") {
                    PrivacyPolicyView()
                }

                NavigationLink("Terms of Service") {
                    TermsOfServiceView()
                }
            }

            Section {
                NavigationLink("Disclaimers & Citations") {
                    DisclaimersView()
                }

                NavigationLink("GDPR Rights") {
                    GlobalRightsView()
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Legal & Compliance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LegalComplianceView()
}
