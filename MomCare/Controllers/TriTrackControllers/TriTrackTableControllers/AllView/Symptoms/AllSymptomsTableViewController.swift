//
//  AllSymptomsTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 20/01/25.
//

import UIKit
import EventKit

class AllSymptomsTableViewController: UITableViewController {
    var symptoms: [EKEvent]? = []

    override func viewDidLoad() {
        super.viewDidLoad()

        symptoms = EventKitHandler.shared.fetchSymptoms()
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
}
