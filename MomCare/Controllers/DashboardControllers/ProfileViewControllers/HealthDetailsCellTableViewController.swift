//
//  HealthDetailsCellTableViewController.swift
//  MomCare
//
//  Created by Nupur on 13/06/25.
//

import UIKit

class HealthDetailsCellTableViewController: UITableViewController {
    
    var healthProfile: HealthProfileType?
    var selectedCells: Set<Int> = []

     var healthList: [String] {
         switch healthProfile {
         case .preExistingCondition:
             return PreExistingCondition.allCases.map { $0.rawValue }
         case .intolerance:
             return Intolerance.allCases.map { $0.rawValue }
         case .dietaryPreference:
             return DietaryPreference.allCases.map { $0.rawValue }
         case .none:
             return []
         }
     }

     override func viewDidLoad() {
         super.viewDidLoad()
         self.title = healthListtitle()
     }

     func healthListtitle() -> String {
         switch healthProfile {
         case .preExistingCondition: return "Pre-Existing Conditions"
         case .intolerance: return "Intolerances"
         case .dietaryPreference: return "Dietary Preferences"
         case .none: return ""
         }
     }

     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return healthList.count
     }

     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "HealthDetailCell", for: indexPath)
         cell.textLabel?.text = healthList[indexPath.row]
         
         cell.accessoryType = selectedCells.contains(indexPath.row) ? .checkmark : .none
         
         return cell
     }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if selectedCells.contains(indexPath.row) {
            selectedCells.remove(indexPath.row)
        } else {
            selectedCells.insert(indexPath.row)
        }

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

}
