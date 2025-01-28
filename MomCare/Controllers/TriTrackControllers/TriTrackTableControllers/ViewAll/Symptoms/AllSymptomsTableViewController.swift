//
//  AllSymptomsTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 20/01/25.
//

import UIKit

class AllSymptomsTableViewController: UITableViewController {
    var symptoms: [TriTrackSymptom] = MomCareUser.shared.symptoms

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return symptoms.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllSymptomsTableViewCell", for: indexPath) as? AllSymptomsTableViewCell

        guard let cell else { fatalError() }

        cell.updateElements(with: symptoms[indexPath.row])

        return cell
    }
}
