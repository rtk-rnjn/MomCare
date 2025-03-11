//
//  SymptomsTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit
import EventKit

class SymptomsTableViewController: UITableViewController {
    var events: [EKEvent]? = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        refreshData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return events?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SymptomsCell", for: indexPath) as? SymptomsTableViewCell

        guard let cell else { fatalError() }
        guard let event = events?[indexPath.section] else { return cell }

        cell.updateElements(with: event)

        // config as per prototype
        cell.backgroundColor = UIColor(hex: "F2F2F7")
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
        events = AppointmentsTableViewController.fetchOldEvents()
        tableView.reloadData()
    }

}
