import SwiftUI
import UIKit

struct ProfileSection: Identifiable {
    var id: UUID = .init()
    let rows: [ProfileRow]
}

struct ProfileRow: Identifiable {
    var id: UUID = .init()

    let title: String
    let systemImage: String
    let type: ProfileRowType
}

private let sections: [ProfileSection] = [
    ProfileSection(rows: [
        ProfileRow(title: "Personal Information", systemImage: "person.crop.circle", type: .personalInfo),
        ProfileRow(title: "Health Information", systemImage: "heart.text.square", type: .healthInfo)
//        ProfileRow(title: "Notifications", systemImage: "bell.badge", type: .notifications)
    ]),

    ProfileSection(rows: [
        ProfileRow(title: "Account and Security", systemImage: "lock.shield", type: .security),
        ProfileRow(title: "Legal & Compliance", systemImage: "doc.text", type: .legal)
    ]),

    ProfileSection(rows: [
        ProfileRow(title: "About MomCare+", systemImage: "info.circle", type: .aboutApp)
    ]),

//    ProfileSection(rows: [
//        ProfileRow(title: "MomCare+ Watch", systemImage: "applewatch", type: .watch)
//    ]),

    ProfileSection(rows: [
        ProfileRow(title: "Account Management", systemImage: "gearshape", type: .accountManagement)
    ]),
    ProfileSection(rows: [
        ProfileRow(title: "Sign Out", systemImage: "", type: .signOut)
    ]),

    ProfileSection(rows: [
        ProfileRow(title: "footer", systemImage: "", type: .footerText)
    ])
]

struct ProfileView: View {

    @State private var showSignOutAlert = false

    var body: some View {
        List {
            ForEach(sections.indices, id: \.self) { sectionIndex in
                Section {
                    ForEach(sections[sectionIndex].rows) { row in

                        switch row.type {

                        case .footerText:
                            footerView

                        case .signOut:
                            Button {
                                showSignOutAlert = true
                            } label: {
                                Text("Sign Out")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.red)
                                    .frame(maxWidth: .infinity)
                            }

                        default:
                            NavigationLink {
                                destinationView(for: row.type)
                            } label: {
                                rowView(row)
                            }
                        }
                    }
                }
            }
            
        }
        .navigationTitle("Profile")
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .alert("Sign Out?", isPresented: $showSignOutAlert) {

            Button("Cancel", role: .cancel) {}

            Button("Sign Out", role: .destructive) {
                performSignOut()
            }

        } message: {
            Text("You will need to log in again to access your MomCare+ account.")
        }
    }

    // MARK: Row View

    private func rowView(_ row: ProfileRow) -> some View {

        HStack(spacing: 12) {

            Image(systemName: row.systemImage)
                .foregroundStyle(Color("primaryAppColor"))

            Text(row.title)
        }
    }

    // MARK: Footer

    private var footerView: some View {

        VStack(spacing: 4) {

            Text("Your experience matters to us.")
                .foregroundStyle(.secondary)

            Text("Connect with Us")
                .foregroundStyle(Color("primaryAppColor"))
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding(.vertical, 8)
        .listRowBackground(Color.clear)
    }

    // MARK: Navigation

    @ViewBuilder
    private func destinationView(for type: ProfileRowType) -> some View {

        switch type {

        case .personalInfo:
            ProfilePersonalInfoView(name: authenticationService.userModel?.fullName ?? "Not Set", dateOfBirth: authenticationService.userModel?.dateOfBirth ?? .init())

        case .healthInfo:
            ProfileHealthInfoView()

        case .security:
            ProfileAccountSecurityView()

        case .legal:
            LegalComplianceView()

        case .aboutApp:
            AboutMomCareView()

        case .accountManagement:
            ProfileAccountManagementView()

        default:
            EmptyView()
        }
    }

    // MARK: Sign Out

    private func performSignOut() {

        Task {
             await authenticationService.logout()
        }
    }
    
    @EnvironmentObject private var authenticationService: AuthenticationService
}
