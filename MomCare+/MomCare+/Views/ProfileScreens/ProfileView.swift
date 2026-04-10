import SwiftUI
import TipKit
import UIKit

struct ProfileView: View {
    // MARK: Internal

    var body: some View {
        List {
            Section {
                NavigationLink {
                    ProfilePersonalInfoView(
                        name: authenticationService.userModel?.fullName ?? "Not Set",
                        dateOfBirth: authenticationService.userModel?.dateOfBirth ?? .init(),
                        height: authenticationService.userModel?.height,
                        currentWeight: authenticationService.userModel?.currentWeight,
                        prePregnancyWeight: authenticationService.userModel?.prePregnancyWeight
                    )
                } label: {
                    Label("Personal Information", systemImage: "person.crop.circle")
                }

                NavigationLink {
                    ProfileHealthInfoView()
                } label: {
                    Label("Health Information", systemImage: "heart.text.square")
                }
            }

            Section {
                NavigationLink {
                    ProfileAccountSecurityView()
                } label: {
                    Label("Account & Security", systemImage: "lock.shield")
                }

                NavigationLink {
                    ProfileNotificationsView()
                } label: {
                    Label("Notifications", systemImage: "bell")
                }

                NavigationLink {
                    LegalComplianceView()
                } label: {
                    Label("Legal & Compliance", systemImage: "doc.text")
                }
            }

            Section {
                NavigationLink {
                    AboutMomCareView()
                } label: {
                    Label("About MomCare+", systemImage: "info.circle")
                }

                NavigationLink {
                    WhatsNewView()
                } label: {
                    Label("What's New", systemImage: "sparkles")
                }
            }

            Section {
                NavigationLink {
                    ProfileAccountManagementView()
                } label: {
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
                .accessibilityLabel("Sign out")
                .accessibilityHint("Signs you out of your MomCare+ account")
            }

            Section {
                footerView
            }
        }
        .navigationTitle(AppTab.settings.title)
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
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
                .accessibilityLabel("Connect with Us")
                .accessibilityHint("Opens email to contact support")
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
