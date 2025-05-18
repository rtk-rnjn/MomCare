//
//  AllAppointmentsTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 20/01/25.
//

import UIKit
import EventKit

class AllAppointmentsTableViewController: UITableViewController {

    var events: [EKEvent]? = []
    var delegate: EventKitHandlerDelegate = .init()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        events = EventKitHandler.shared.fetchAppointments()
        delegate.viewController = self
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllAppointmentsTableViewCell", for: indexPath) as? AllAppointmentsTableViewCell
        guard let cell else { fatalError("likhe jo khat tujhe, wo teri yaad me 🎶") }

        guard let appointment = events?[indexPath.row] else { return cell }
        cell.updateElements(with: appointment)

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
                self.tableView.reloadData()
            }

            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}
