//
//  SymptomsTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit

class SymptomsTableViewController: UITableViewController {
    var data: [TriTrackSymptom] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    func refreshData() {
        self.data = MomCareUser.shared.symptoms
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SymptomsCell", for: indexPath) as? SymptomsTableViewCell

        guard let cell = cell else { return UITableViewCell() }
        
        cell.updateElements(with: data[indexPath.section])
        cell.showsReorderControl = false
        
        /* config as per prototype */
        cell.backgroundColor = Converters.convertHexToUIColor(hex: "F2F2F7")
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

}
