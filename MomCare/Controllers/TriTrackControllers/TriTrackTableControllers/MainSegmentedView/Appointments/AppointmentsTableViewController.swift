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

    var delegate: EventKitHandlerDelegate = .init()
    var eventsViewController: EventsViewController?
    var events: [EventInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate.viewController = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Task {
            events = await fetchEvents()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return events.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentCell", for: indexPath) as? AppointmentsTableViewCell

        guard let cell else { fatalError("Failed to dequeue AppointmentsTableViewCell") }

        cell.updateElements(with: events[indexPath.section])
        cell.showsReorderControl = false

        cell.backgroundColor = UIColor(hex: "F2F2F7")
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        cell.clipsToBounds = true

        return cell
    }

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        let event = events[indexPath.row]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: previewProvider(for: indexPath)) { _ in
            let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
                Task {
                    await self.delegate.presentEKEventEditViewController(with: event)
                }
            }

            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                Task {
                    await EventKitHandler.shared.deleteEvent(event: event)
                }
                self.refreshData()
            }

            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = events[indexPath.section]

        Task {
            await delegate.presentEKEventViewController(with: event)
            DispatchQueue.main.async {
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 3
    }

    func fetchEvents() async -> [EventInfo] {
        let selectedDate = eventsViewController?.triTrackViewController?.selectedFSCalendarDate ?? Date()
        let startDate = Calendar.current.startOfDay(for: selectedDate)
        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!

        return await EventKitHandler.shared.fetchAppointments(startDate: startDate, endDate: endDate)
    }

    func refreshData() {
        Task {
            events = await fetchEvents()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: Private

    private func previewProvider(for indexPath: IndexPath) -> UIContextMenuContentPreviewProvider? {
        let event = events[indexPath.section]
        return {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "AppointmentCell") as? AppointmentsTableViewCell
            guard let cell else {
                fatalError("Failed to dequeue AppointmentsTableViewCell for preview")
            }
            return EventDetailsViewController(cell: cell) {
                return event
            }
        }
    }

}
