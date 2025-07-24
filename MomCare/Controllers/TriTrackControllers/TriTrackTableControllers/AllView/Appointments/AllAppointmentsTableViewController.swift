//
//  AllAppointmentsTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 20/01/25.
//

import UIKit
import EventKit

class AllAppointmentsTableViewController: UITableViewController {

    // MARK: Internal

    var searchController: UISearchController = .init(searchResultsController: nil)
    var events: [EventInfo] = []
    var groupedEvents: [Date: [EventInfo]] = [:]

    var delegate: EventKitHandlerDelegate = .init()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Task {
            events = await EventKitHandler.shared.fetchAllAppointments()
            DispatchQueue.main.async {
                self.groupEventsByDate()
                self.tableView.reloadData()
            }
        }

        delegate.viewController = self

        tableView.sectionHeaderTopPadding = 10

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let defaultAppearance = UINavigationBarAppearance()
        defaultAppearance.configureWithOpaqueBackground()
        defaultAppearance.backgroundColor = .systemBackground // or whatever your default color is
        defaultAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        defaultAppearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = defaultAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = defaultAppearance
    }

    override func viewDidLoad() {
        setupAppointmentHeader()
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
                Task {
                    await self.delegate.presentEKEventEditViewController(with: event)
                }
            }

            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                Task {
                    await EventKitHandler.shared.deleteEvent(event: event)

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }

            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = groupedEvents[groupedEvents.keys.sorted()[indexPath.section]]?[indexPath.row]

        guard let event else { return }

        Task {
            await delegate.presentEKEventViewController(with: event)
            DispatchQueue.main.async {
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }

    func groupEventsByDate() {
        groupedEvents = [:]

        for event in events {
            let date = Calendar.current.startOfDay(for: event.startDate ?? .init())
            if groupedEvents[date] == nil {
                groupedEvents[date] = []
            }
            groupedEvents[date]?.append(event)
        }
    }

    // MARK: Private

    private func setupAppointmentHeader() {
        let headerLabel = UILabel()
        headerLabel.text = "Appointments"
        headerLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        headerLabel.textColor = UIColor(hex: "924350")
        headerLabel.textAlignment = .left
        headerLabel.numberOfLines = 1
        headerLabel.backgroundColor = .clear
        headerLabel.translatesAutoresizingMaskIntoConstraints = false

        // Calculate height for the label
        let headerHeight: CGFloat = 60
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: headerHeight))
        headerView.backgroundColor = .clear
        headerView.addSubview(headerLabel)

        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -15),
            headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8)
        ])

        tableView.tableHeaderView = headerView
    }

}
