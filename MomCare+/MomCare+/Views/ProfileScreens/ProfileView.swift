import SwiftUI
import UIKit

enum ProfileDestination: Hashable {
    case personalInfo
    case healthInfo
    case accountSecurity
    case notifications
    case legal
    case about
    case whatsNew
    case accountManagement
}

struct ProfileView: View {
    // MARK: Internal

    var body: some View {
        List {
            Section {
                NavigationLink(value: ProfileDestination.personalInfo) {
                    Label("Personal Information", systemImage: "person.crop.circle")
                }

                NavigationLink(value: ProfileDestination.healthInfo) {
                    Label("Health Information", systemImage: "heart.text.square")
                }
            }

            Section {
                NavigationLink(value: ProfileDestination.accountSecurity) {
                    Label("Account & Security", systemImage: "lock.shield")
                }

                NavigationLink(value: ProfileDestination.notifications) {
                    Label("Notifications", systemImage: "bell")
                }

                NavigationLink(value: ProfileDestination.legal) {
                    Label("Legal & Compliance", systemImage: "doc.text")
                }
            }

            Section {
                NavigationLink(value: ProfileDestination.about) {
                    Label("About MomCare+", systemImage: "info.circle")
                }

                NavigationLink(value: ProfileDestination.whatsNew) {
                    Label("What's New", systemImage: "sparkles")
                }
            }

            Section {
                NavigationLink(value: ProfileDestination.accountManagement) {
                    Label("Account Management", systemImage: "gearshape")
                }
            }

            Section {
                Button {
                    showSignOutAlert = true
                } label: {
                    Text("Sign Out")
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                }
                .accessibilityLabel(String(localized: "a11y_sign_out_label"))
                .accessibilityHint(String(localized: "a11y_sign_out_hint"))
            }

            Section {
                footerView
            }
        }
        .navigationTitle(AppTab.settings.title)
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationDestination(for: ProfileDestination.self) { destination in
            switch destination {
            case .personalInfo:
                ProfilePersonalInfoView()
            case .healthInfo:
                ProfileHealthInfoView()
            case .accountSecurity:
                ProfileAccountSecurityView()
            case .notifications:
                ProfileNotificationsView()
            case .legal:
                LegalComplianceView()
            case .about:
                AboutMomCareView()
            case .whatsNew:
                WhatsNewView()
            case .accountManagement:
                ProfileAccountManagementView()
            }
        }
        .alert("Sign Out?", isPresented: $showSignOutAlert) {
            MCCancelButton {}

            Button("Sign Out", role: .destructive) {
                Task {
                    await authenticationService.logout()
                }
            }
        } message: {
            Text("You will need to log in again to access your MomCare+ account. All Events and data will remain intact.")
        }
    }

    // MARK: Private

    @State private var showSignOutAlert = false

    @EnvironmentObject private var authenticationService: MCAuthenticationService
    @Environment(\.openURL) private var openURL

    private var footerView: some View {
        VStack(spacing: 4) {
            Text("Your experience matters to us")
                .foregroundStyle(.secondary)

            Text("Connect with Us")
                .foregroundStyle(Color("primaryAppColor"))
                .fontWeight(.medium)
                .onTapGesture {
                    let url = "mailto:support.momcare@vision-labs.site"
                    if let mailURL = URL(string: url) {
                        openURL(mailURL)
                    }
                }
                .accessibilityLabel(String(localized: "a11y_connect_with_us_label"))
                .accessibilityHint(String(localized: "a11y_contact_email_hint"))
                .accessibilityAddTraits(.isButton)
                .accessibilityAction(.default) {
                    let url = "mailto:support.momcare@vision-labs.site"
                    if let mailURL = URL(string: url) {
                        openURL(mailURL)
                    }
                }
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding(.vertical, 8)
        .listRowBackground(Color.clear)
    }
}
