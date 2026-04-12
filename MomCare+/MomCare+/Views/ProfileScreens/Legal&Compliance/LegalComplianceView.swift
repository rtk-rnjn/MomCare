import SwiftUI

struct LegalComplianceView: View {
    var body: some View {
        List {
            Section {
                NavigationLink("Privacy Policy") {
                    PrivacyPolicyView()
                }
                .accessibilityHint(String(localized: "a11y_privacy_policy_hint"))

                NavigationLink("Terms of Service") {
                    TermsOfServiceView()
                }
                .accessibilityHint(String(localized: "a11y_terms_of_service_hint"))
            }

            Section {
                NavigationLink("Disclaimers & Citations") {
                    DisclaimersView()
                }
                .accessibilityHint(String(localized: "a11y_disclaimer_hint"))

                NavigationLink("GDPR Rights") {
                    GlobalRightsView()
                }
                .accessibilityHint(String(localized: "a11y_gdpr_hint"))
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
