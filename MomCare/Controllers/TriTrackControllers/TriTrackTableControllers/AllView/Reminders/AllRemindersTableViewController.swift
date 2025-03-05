//
//  AllRemindersTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 20/01/25.
//

import UIKit
import EventKit

class AllRemindersTableViewController: UITableViewController {

    var reminders: [EKReminder] = []
    var store: EKEventStore?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        store = TriTrackViewController.eventStore
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

        cell.updateElements(with: reminders[indexPath.row], for: store)

        return cell
    }
    
    private func fetchReminders() {
        let ekCalendars = getCalendar(with: "TriTrackReminder")

        guard let store, let ekCalendars else { return }

        let predicate = store.predicateForReminders(in: ekCalendars)
        store.fetchReminders(matching: predicate) { reminders in
            guard let reminders else { return }

            self.reminders = reminders

            DispatchQueue.main.async {
                self.tableView.reloadData()
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
