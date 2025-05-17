//
//  AppointmentsTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit
import EventKit

class AppointmentsTableViewController: UITableViewController {

    var delegate: EventKitHandlerDelegate = .init()
    var eventsViewController: EventsViewController?
    var events: [EKEvent]? = []

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate.viewController = self
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

        guard let cell else { fatalError("Failed to dequeue AppointmentsTableViewCell") }
        guard let events else { return cell }

        cell.updateElements(with: events[indexPath.section])
        cell.showsReorderControl = false

        cell.backgroundColor = UIColor(hex: "F2F2F7")
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        cell.clipsToBounds = true

        return cell
    }

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let events else { return nil }

        let event = events[indexPath.row]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
                self.delegate.presentEKEventEditViewController(with: event)
            }

            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                EventKitHandler.shared.deleteEvent(event: event)
                self.refreshData()
            }

            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let event = events?[indexPath.section] else { return }

        delegate.presentEKEventViewController(with: event)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 3
    }

    func fetchEvents() -> [EKEvent]? {
        let startDate = eventsViewController?.triTrackViewController?.selectedFSCalendarDate ?? Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!

        return EventKitHandler.shared.fetchAppointments(startDate: startDate, endDate: endDate)
    }

    func refreshData() {
        events = fetchEvents()
        tableView.reloadData()
    }
}
