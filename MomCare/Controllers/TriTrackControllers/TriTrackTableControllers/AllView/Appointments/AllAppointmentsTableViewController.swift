//
//  AllAppointmentsTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 20/01/25.
//

import UIKit
import EventKit
import EventKitUI

class AllAppointmentsTableViewController: UITableViewController {

    var events: [EKEvent]? = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        events = AppointmentsTableViewController.fetchEvents()
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
                self.presentEKEventEditViewController(with: event)
            }

            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                try? TriTrackViewController.eventStore.remove(event, span: .thisEvent, commit: true)
                self.tableView.reloadData()
            }

            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}

extension AllAppointmentsTableViewController: EKEventEditViewDelegate, EKEventViewDelegate {
    nonisolated func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        switch action {
        case .saved:
            break
        case .canceled, .deleted:
            DispatchQueue.main.async {
                controller.dismiss(animated: true)
            }

        @unknown default:
            break
        }
    }

    nonisolated func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {
        switch action {
        case .done:
            DispatchQueue.main.async {
                controller.dismiss(animated: true)
            }

        default:
            break
        }
    }

    func presentEKEventEditViewController(with event: EKEvent?) {
        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.eventStore = TriTrackViewController.eventStore
        eventEditViewController.event = .none

        eventEditViewController.editViewDelegate = self

        present(eventEditViewController, animated: true, completion: nil)
    }

    func presentEKEventViewController(with event: EKEvent) {
        let eventViewController = EKEventViewController()
        eventViewController.event = event
        eventViewController.allowsEditing = true
        eventViewController.allowsCalendarPreview = true

        let navigationController = UINavigationController(rootViewController: eventViewController)
        eventViewController.delegate = self

        present(navigationController, animated: true)
    }
}
