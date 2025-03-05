//
//  AllAppointmentsTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 20/01/25.
//

import UIKit
import EventKit

class AllAppointmentsTableViewController: UITableViewController {

    var appointments: [EKEvent]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appointments = AppointmentsTableViewController.fetchEvents()
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appointments?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllAppointmentsTableViewCell", for: indexPath) as? AllAppointmentsTableViewCell
        guard let cell else { fatalError("likhe jo khat tujhe, wo teri yaad me 🎶") }

        guard let appointment = appointments?[indexPath.row] else { return cell }        
        cell.updateElements(with: appointment)

        return cell
    }
}
