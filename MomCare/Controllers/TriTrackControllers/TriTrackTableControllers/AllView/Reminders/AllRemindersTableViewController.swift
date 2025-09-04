//

//  AllRemindersTableViewController.swift

//  MomCare

//

//  Created by Ritik Ranjan on 20/01/25.

//

import UIKit

import EventKit

class AllRemindersTableViewController: UITableViewController {

    // MARK: Internal

    var reminders: [ReminderInfo] = []

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        let appearance = UINavigationBarAppearance()

        appearance.configureWithOpaqueBackground()

        appearance.backgroundColor = UIColor.systemBackground

        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance

        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        setupRemindersHeader()

        fetchAllReminders()

    }

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        let defaultAppearance = UINavigationBarAppearance()

        defaultAppearance.configureWithOpaqueBackground()

        defaultAppearance.backgroundColor = .systemBackground // or whatever your default color is

        defaultAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]

        defaultAppearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = defaultAppearance

        navigationController?.navigationBar.scrollEdgeAppearance = defaultAppearance

    }

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return reminders.count

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "AllRemindersTableViewCell", for: indexPath) as? AllRemindersTableViewCell

        guard let cell else { fatalError() }

        cell.updateElements(with: reminders[indexPath.row])

        return cell

    }

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        let reminder = reminders[indexPath.row]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: previewProvider(for: indexPath)) { _ in

            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in

                Task {

                    await EventKitHandler.shared.deleteReminder(reminder: reminder)

                    DispatchQueue.main.async {

                        self.reminders.remove(at: indexPath.row)

                        self.tableView.reloadData()

                    }

                }

            }

            return UIMenu(title: "", children: [deleteAction])

        }

    }

    // MARK: Private

    private func setupRemindersHeader() {

        let headerLabel = UILabel()

        headerLabel.text = "Reminders"

        headerLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)

        headerLabel.textColor = UIColor(hex: "924350")

        headerLabel.textAlignment = .left

        headerLabel.numberOfLines = 1

        headerLabel.backgroundColor = .clear

        headerLabel.translatesAutoresizingMaskIntoConstraints = false

        // Calculate height for the label

        let headerHeight: CGFloat = 60

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: headerHeight))

        headerView.backgroundColor = .clear

        headerView.addSubview(headerLabel)

        NSLayoutConstraint.activate([

            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16), headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16), headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -15), headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8)

        ])

        tableView.tableHeaderView = headerView

    }

    private func fetchAllReminders() {

        Task {

            await EventKitHandler.shared.fetchAllReminders { reminders in

                DispatchQueue.main.async {

                    self.reminders = reminders

                    self.tableView.reloadData()

                }

            }

        }

    }

    private func previewProvider(for indexPath: IndexPath) -> () -> UIViewController? {

        return {

            let cell = self.tableView.dequeueReusableCell(withIdentifier: "AllRemindersTableViewCell", for: indexPath) as? AllRemindersTableViewCell

            guard let cell else { fatalError("Failed to dequeue AllRemindersTableViewCell") }

            let reminder = self.reminders[indexPath.row]

            return ReminderDetailsViewController(reminder: reminder, cell: cell)

        }

    }

}
