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

    var data: [EKReminder] = []
    let store: EKEventStore = .init()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as? RemindersTableViewCell

        guard let cell else { return UITableViewCell() }

        cell.updateElements(with: data[indexPath.section])
        cell.showsReorderControl = false

        // config as per prototype
        cell.backgroundColor = Converters.convertHexToUIColor(hex: "F2F2F7")
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

    func refreshData() {
        fetchReminders()
    }

    // MARK: Private

    private func fetchReminders() {
        let ekCalendars = getCalendar(with: "TriTrackReminder")

        let predicate = store.predicateForReminders(in: ekCalendars)
        store.fetchReminders(matching: predicate, completion: reminderCompletionHandler)
    }

    private func reminderCompletionHandler(reminders: [EKReminder]?) {
        guard let reminders else { return }
        data = reminders

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    private func getCalendar(with identifierKey: String) -> [EKCalendar]? {
        if let identifier = UserDefaults.standard.string(forKey: identifierKey), let calendar = store.calendar(withIdentifier: identifier) {
            return [calendar]
        }

        return []
    }

}
