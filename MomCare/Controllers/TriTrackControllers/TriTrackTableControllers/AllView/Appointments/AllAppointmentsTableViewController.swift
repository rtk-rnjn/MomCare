//
//  AllAppointmentsTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 20/01/25.
//

import UIKit
import EventKit

class AllAppointmentsTableViewController: UITableViewController {
    
    
    var searchController: UISearchController = .init(searchResultsController: nil)
    var events: [EKEvent] = []
    var groupedEvents: [Date: [EKEvent]] = [:]

    var delegate: EventKitHandlerDelegate = .init()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        events = EventKitHandler.shared.fetchAllAppointments()
        groupEventsByDate()
        tableView.reloadData()

        delegate.viewController = self
        
        tableView.sectionHeaderTopPadding = 10
    }
    
    func groupEventsByDate() {
        groupedEvents = [:]
        
        for event in events {
            let date = Calendar.current.startOfDay(for: event.startDate)
            if groupedEvents[date] == nil {
                groupedEvents[date] = []
            }
            groupedEvents[date]?.append(event)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return groupedEvents.keys.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedEvents[groupedEvents.keys.sorted()[section]]?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = groupedEvents.keys.sorted()[section]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        // if todays date, set the text color to red
        let date = groupedEvents.keys.sorted()[section]
        let today = Calendar.current.startOfDay(for: Date())
        if date == today {
            header.textLabel?.textColor = .red
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllAppointmentsTableViewCell", for: indexPath) as? AllAppointmentsTableViewCell
        guard let cell else { fatalError("likhe jo khat tujhe, wo teri yaad me 🎶") }

        let appointment = groupedEvents[groupedEvents.keys.sorted()[indexPath.section]]?[indexPath.row]
        guard let appointment else { return cell }
        cell.updateElements(with: appointment)

        return cell
    }

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        let event = groupedEvents[groupedEvents.keys.sorted()[indexPath.section]]?[indexPath.row]
        guard let event else { return nil }

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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = groupedEvents[groupedEvents.keys.sorted()[indexPath.section]]?[indexPath.row]
        
        guard let event else { return }

        delegate.presentEKEventViewController(with: event)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
