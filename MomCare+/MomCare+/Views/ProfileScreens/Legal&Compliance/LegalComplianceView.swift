import SwiftUI

struct LegalComplianceView: View {
    var body: some View {
        List {
            Section {
                NavigationLink("Privacy Policy") {
                    PrivacyPolicyView()
                }
                .accessibilityHint("View the MomCare+ privacy policy")

                NavigationLink("Terms of Service") {
                    TermsOfServiceView()
                }
                .accessibilityHint("View the MomCare+ terms of service")
            }

            Section {
                NavigationLink("Disclaimers & Citations") {
                    DisclaimersView()
                }
                .accessibilityHint("View medical disclaimers and citations")

                NavigationLink("GDPR Rights") {
                    GlobalRightsView()
                }
                .accessibilityHint("View your data privacy rights under GDPR")
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
