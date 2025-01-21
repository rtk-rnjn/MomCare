//
//  AllAppointmentsTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 20/01/25.
//

import UIKit

class AllAppointmentsTableViewController: UITableViewController {

    var appointments = MomCareUser.shared.events

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appointments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllAppointmentsTableViewCell", for: indexPath) as? AllAppointmentsTableViewCell

        let appointment = appointments[indexPath.row]
        guard let cell = cell else { return UITableViewCell() }
        cell.updateElements(with: appointment)

        return cell
    }
}
