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
    var store: EKEventStore?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let eventsViewController else { return }
        store = TriTrackViewController.eventStore

    }

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

        guard let cell, let reminders else { fatalError("aaj fir tum pe pyar aaya hai") }

        cell.updateElements(with: reminders[indexPath.section], for: store)
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
                try? self.store?.remove(reminder, commit: true)
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
                    destinationVC.store = store
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
        let ekCalendars = getCalendar(with: "TriTrackReminder")

        // Thank you Kiran Ma'am for pointing it out.
        let selectedDate = eventsViewController?.triTrackViewController?.selectedDate ?? Date()

        guard let store, let ekCalendars else { return }

        let predicate = store.predicateForReminders(in: ekCalendars)
        store.fetchReminders(matching: predicate) { reminders in
            guard let reminders else { return }

            self.reminders = reminders.filter { reminder in
                let date = reminder.dueDateComponents?.date
                guard let date else { return false }
                return Calendar.current.isDate(date, inSameDayAs: selectedDate)
            }
        }
    }

    private func getCalendar(with identifierKey: String) -> [EKCalendar]? {
        guard let store else { return [] }

        if let identifier = UserDefaults.standard.string(forKey: identifierKey), let calendar = store.calendar(withIdentifier: identifier) {
            return [calendar]
        }

        return []
    }

}
