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

        fetchReminders()
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

    // MARK: Private

    private func fetchReminders() {
        Task {
            await EventKitHandler.shared.fetchReminders { reminders in
                DispatchQueue.main.async {
                    self.reminders = reminders
                    self.tableView.reloadData()
                }
            }
        }
    }
}
