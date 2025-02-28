//
//  AppointmentsTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit
import EventKit

class AppointmentsTableViewController: UITableViewController {

    // MARK: Internal

    var eventsViewController: EventsViewController?

    var events: [EKEvent]? = []
    var store: EKEventStore?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let eventsVC = eventsViewController else { fatalError("eventsViewController is nil") }
        store = TriTrackViewController.eventStore
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let events else { return 0 }

        return events.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentCell", for: indexPath) as? AppointmentsTableViewCell

        guard let cell, let events else { fatalError("mere rang me rangne wali 🎶") }

        cell.updateElements(with: events[indexPath.section])
        cell.showsReorderControl = false

        cell.backgroundColor = UIColor(hex: "F2F2F7")
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        cell.clipsToBounds = true

        return cell
    }

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let triTrackVC = eventsViewController?.triTrackViewController else { return nil }
        guard let events else { return nil }

        let event = events[indexPath.row]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
                triTrackVC.presentEKEventEditViewController(with: event)
            }

            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                try? self.store?.remove(event, span: .thisEvent, commit: true)
                self.refreshData()
            }

            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let triTrackVC = eventsViewController?.triTrackViewController, let events else { return }
        triTrackVC.presentEKEventViewController(with: events[indexPath.section])
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 3
    }

    func refreshData() {
        events = fetchEvents()
        tableView.reloadData()
    }

    // MARK: Private

    private func fetchEvents() -> [EKEvent]? {
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
        let ekCalendars = getCalendar(with: "TriTrackEvent")

        let predicate = store?.predicateForEvents(withStart: startDate, end: endDate, calendars: ekCalendars)
        if let predicate {
            return store?.events(matching: predicate)
        }
        return []
    }

    private func getCalendar(with identifierKey: String) -> [EKCalendar]? {
        if let identifier = UserDefaults.standard.string(forKey: identifierKey), let calendar = store?.calendar(withIdentifier: identifier) {
            return [calendar]
        }

        return []
    }

}
