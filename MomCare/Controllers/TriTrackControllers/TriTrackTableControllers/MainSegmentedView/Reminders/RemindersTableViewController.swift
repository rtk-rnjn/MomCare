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

    var reminders: [ReminderInfo] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return reminders.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as? RemindersTableViewCell

        guard let cell else { fatalError("Failed to dequeue RemindersTableViewCell") }

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
        performSegue(withIdentifier: "segueShowEKReminderViewController", sender: reminders[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowEKReminderViewController", let destinationNC = segue.destination as? UINavigationController, let destinationVC = destinationNC.topViewController as? EKReminderViewController {
            destinationVC.reminder = sender as? ReminderInfo
            destinationVC.reloadHandler = {
                self.refreshData()
            }
        }
    }

    func refreshData() {
        fetchReminders()
    }

    @IBAction func unwindToRemindersTableViewController(_ segue: UIStoryboardSegue) {}

    // MARK: Private

    private func previewProvider(for indexPath: IndexPath) -> () -> UIViewController? {
        return {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as? RemindersTableViewCell
            guard let cell else { fatalError("Failed to dequeue RemindersTableViewCell") }
            let reminder = self.reminders[indexPath.row]
            return ReminderDetailsViewController(reminder: reminder, cell: cell)
        }
    }

    private func fetchReminders() {
        let selectedFSCalendarDate = eventsViewController?.triTrackViewController?.selectedFSCalendarDate ?? Date()
        let startDate = Calendar.current.startOfDay(for: selectedFSCalendarDate)
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        Task {
            await EventKitHandler.shared.fetchReminders(startDate: startDate, endDate: endDate) { reminders in
                DispatchQueue.main.async {
                    self.reminders = reminders
                    self.tableView.reloadData()
                }
            }
        }
    }
}
