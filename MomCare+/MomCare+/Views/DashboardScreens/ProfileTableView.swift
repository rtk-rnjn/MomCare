import SwiftUI
import UIKit

private let sections: [ProfileSection] = [
    ProfileSection(title: nil, rows: [
        ProfileRow(title: "Personal Information", systemImage: "person.crop.circle", type: .personalInfo),
        ProfileRow(title: "Health Information", systemImage: "heart.text.square", type: .healthInfo),
        ProfileRow(title: "Notifications", systemImage: "bell.badge", type: .notifications)
    ]),

    ProfileSection(title: nil, rows: [
        ProfileRow(title: "Account and Security", systemImage: "lock.shield", type: .security),
        ProfileRow(title: "Legal & Compliance", systemImage: "doc.text", type: .legal)
    ]),

    ProfileSection(title: nil, rows: [
        ProfileRow(title: "About MomCare+", systemImage: "info.circle", type: .aboutApp)
    ]),

    ProfileSection(title: nil, rows: [
        ProfileRow(title: "MomCare+ Watch", systemImage: "applewatch", type: .watch)
    ]),

    ProfileSection(title: nil, rows: [
        ProfileRow(title: "Account Management", systemImage: "gearshape", type: .accountManagement)
    ]),
    ProfileSection(title: nil, rows: [
        ProfileRow(title: "Sign Out", systemImage: "", type: .signOut)
    ]),

    ProfileSection(title: nil, rows: [
        ProfileRow(title: "footer", systemImage: "", type: .footerText)
    ])
]

final class ProfileTableView: UITableViewController {

    // MARK: Lifecycle

    init() {
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    // MARK: Internal

    var authenticationService: AuthenticationService?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Profile"

        tableView.backgroundColor = .systemGroupedBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        tableView.backgroundColor = .systemGroupedBackground
    }

    override func numberOfSections(in _: UITableView) -> Int {
        sections.count
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let row = sections[indexPath.section].rows[indexPath.row]

        if row.type == .footerText {
            var config = UIListContentConfiguration.subtitleCell()

            let primary = UIColor(named: "primaryAppColor") ?? .systemBlue

            let attributed = NSMutableAttributedString(
                string: "Your experience matters to us.\n",
                attributes: [
                    .foregroundColor: UIColor.secondaryLabel,
                    .font: UIFont.systemFont(ofSize: 16)
                ]
            )

            attributed.append(NSAttributedString(
                string: "Connect with Us",
                attributes: [
                    .foregroundColor: primary,
                    .font: UIFont.systemFont(ofSize: 15, weight: .medium)
                ]
            ))

            config.attributedText = attributed
            config.textProperties.alignment = .center

            cell.contentConfiguration = config
            cell.selectionStyle = .none
            cell.backgroundConfiguration = .clear()
            return cell
        }

        var config = UIListContentConfiguration.valueCell()
        config.text = row.title

        if row.type == .signOut {
            var config = UIListContentConfiguration.valueCell()
            config.text = "Sign Out"
            config.textProperties.color = .systemRed
            config.textProperties.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            config.textProperties.alignment = .center

            cell.contentConfiguration = config
            cell.accessoryType = .none
            cell.selectionStyle = .default
            cell.backgroundConfiguration = UIBackgroundConfiguration.listCell()

            return cell
        } else {
            config.image = UIImage(systemName: row.systemImage)
            config.imageProperties.tintColor = UIColor(named: "primaryAppColor")
            cell.accessoryType = .disclosureIndicator
        }

        cell.contentConfiguration = config
        cell.backgroundConfiguration = UIBackgroundConfiguration.listCell()

        return cell
    }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let rowType = sections[indexPath.section].rows[indexPath.row].type

        switch rowType {
        case .personalInfo:
            push(PersonalInfoView(), title: "Personal Information")

        case .healthInfo:
            push(HealthInfoView(), title: "Health Information")

        case .notifications:
            push(NotificationsView(), title: "Notifications")

        case .security:
            push(AccountSecurityView(), title: "Account & Security")

        case .legal:
            push(LegalComplianceView(), title: "Legal & Compliance")

        case .aboutApp:
            push(AboutMomCareView(), title: "About MomCare+")

        case .watch:
            push(MomCareWatchView(), title: "MomCare+ Watch")

        case .accountManagement:
            push(AccountManagementView(), title: "Account Management")

        case .signOut:
            presentSignOutAlert()

        case .footerText:
            break
        }
    }

    // MARK: Private

    private func push(_ view: some View, title: String) {
        let vc = UIHostingController(rootView: view)
        vc.title = title
        navigationController?.pushViewController(vc, animated: true)
    }

    private func presentSignOutAlert() {
        let alert = UIAlertController(
            title: "Sign Out?",
            message: "You will need to log in again to access your MomCare+ account.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            self.performSignOut()
        })

        present(alert, animated: true)
    }

    private func performSignOut() {
        Task {
            await authenticationService?.logout()
        }

        dismiss(animated: true)
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
