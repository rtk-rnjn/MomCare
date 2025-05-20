//
//  SymptomsTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit
import EventKit

class SymptomsTableViewController: UITableViewController {
    var triTrackViewController: TriTrackViewController?
    var delegate: EventKitHandlerDelegate = .init()
    
    var events: [EKEvent] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.delegate.viewController = self
        refreshData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return events.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SymptomsCell", for: indexPath) as? SymptomsTableViewCell

        guard let cell else { fatalError() }
        let event = events[indexPath.section]

        cell.updateElements(with: event)

        cell.backgroundColor = UIColor(hex: "F2F2F7")
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        cell.clipsToBounds = true

        return cell
    }

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
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
        let event = events[indexPath.section]

        delegate.presentEKEventViewController(with: event)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 3
    }

    func refreshData() {
        let selectedFSCalendarDate = triTrackViewController?.selectedFSCalendarDate

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedFSCalendarDate ?? Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        events = EventKitHandler.shared.fetchSymptoms(startDate: startOfDay, endDate: endOfDay)

        tableView.reloadData()
    }

}
