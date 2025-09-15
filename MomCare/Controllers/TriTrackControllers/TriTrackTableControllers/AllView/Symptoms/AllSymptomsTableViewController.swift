//
//  AllSymptomsTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 20/01/25.
//

import UIKit
import EventKit
import SwiftUI

class AllSymptomsTableViewController: UITableViewController {

    // MARK: Internal

    var symptoms: [EventInfo]? = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSymptomsHeader()
        Task {
            symptoms = await EventKitHandler.shared.fetchAllSymptoms()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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
        defaultAppearance.backgroundColor = .systemBackground
        defaultAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        defaultAppearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = defaultAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = defaultAppearance
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return symptoms?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllSymptomsTableViewCell", for: indexPath) as? AllSymptomsTableViewCell

        guard let cell else { fatalError() }
        guard let symptoms else { return cell }

        cell.updateElements(with: symptoms[indexPath.row])

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let symptoms = symptoms else { return }
        let selectedEvent = symptoms[indexPath.row]
        guard let symptomNameToFind = selectedEvent.title else { return }

        guard let symptomToShow = PregnancySymptoms.allSymptoms.first(where: { $0.name == symptomNameToFind }) else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }

        let detailView = SymptomDetailView(symptom: symptomToShow)
        let hostingController = UIHostingController(rootView: detailView)
        navigationController?.pushViewController(hostingController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let event = symptoms?[indexPath.row]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in

            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                guard let event = event else { return }
                Task {
                    await EventKitHandler.shared.deleteEvent(event: event)
                    DispatchQueue.main.async {
                        self.symptoms?.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
                }
            }

            return UIMenu(title: "", children: [deleteAction])
        }
    }

    // MARK: Private

    private func setupSymptomsHeader() {
        let headerLabel = UILabel()
        headerLabel.text = "Symptoms"
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
