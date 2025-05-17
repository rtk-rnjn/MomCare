//
//  RemindersTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit
import EventKit

class RemindersTableViewController: UITableViewController {

    // MARK: Internal

    var eventsViewController: EventsViewController?

    var reminders: [EKReminder]? = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return reminders?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as? RemindersTableViewCell

        guard let cell else { fatalError("Failed to dequeue RemindersTableViewCell") }
        guard let reminders else { return cell }

        cell.updateElements(with: reminders[indexPath.section])
        cell.showsReorderControl = false

        cell.backgroundColor = UIColor(hex: "F2F2F7")
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        cell.clipsToBounds = true

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 3
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let reminders else { return }
        performSegue(withIdentifier: "segueShowEKReminderViewController", sender: reminders[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let reminders else { return nil }

        let reminder = reminders[indexPath.row]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                EventKitHandler.shared.deleteReminder(reminder: reminder)
                self.refreshData()
            }

            return UIMenu(title: "", children: [deleteAction])
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowEKReminderViewController" {
            if let destinationNC = segue.destination as? UINavigationController {
                if let destinationVC = destinationNC.topViewController as? EKReminderViewController {
                    destinationVC.reminder = sender as? EKReminder
                }
            }
        }
    }

    func refreshData() {
        fetchReminders()
    }

    @IBAction func unwindToRemindersTableViewController(_ segue: UIStoryboardSegue) {}

    // MARK: Private

    private func fetchReminders() {
        let selectedFSCalendarDate = eventsViewController?.triTrackViewController?.selectedFSCalendarDate ?? Date()
        reminders = EventKitHandler.shared.fetchReminders(endDate: selectedFSCalendarDate)

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

    }
}
