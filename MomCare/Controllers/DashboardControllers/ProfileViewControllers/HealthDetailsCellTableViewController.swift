//
//  HealthDetailsCellTableViewController.swift
//  MomCare
//
//  Created by Nupur on 13/06/25.
//

import UIKit

class HealthDetailsCellTableViewController: UITableViewController {

    @IBOutlet weak var HealthDetailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PreExistingCondition.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "HealthDetailCell", for: indexPath)
        
        let preExistingCondition = PreExistingCondition.allCases
        // Set the data
        cell.HealthDetailLabel?.text = preExistingCondition[indexPath.row]

        return cell
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = (cell.accessoryType == .checkmark) ? .none : .checkmark
        }
    }


}
