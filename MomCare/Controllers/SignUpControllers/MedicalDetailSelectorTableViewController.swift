//
//  MedicalDetailSelectorTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 14/02/25.
//

import UIKit

class MedicalDetailSelectorTableViewController: UITableViewController {
    var options: [String] = []
    var selectedOptions: [String] = []

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MedicalDetailSelectorTableViewCell", for: indexPath)
        
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = "\(options[indexPath.row])"
        
        cell.contentConfiguration = contentConfig
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MedicalDetailSelectorTableViewCell", for: indexPath)

        if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
            selectedOptions.removeAll { $0 == options[indexPath.row] }
        } else {
            cell.accessoryType = .checkmark
            selectedOptions.append(options[indexPath.row])
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
