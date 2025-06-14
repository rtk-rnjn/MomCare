//
//  HealthDetailsCellTableViewController.swift
//  MomCare
//
//  Created by Nupur on 13/06/25.
//

import UIKit

class HealthDetailsCellTableViewController: UITableViewController {
    
    var healthProfile: HealthProfileType?
    var selectedIndices: Set<Int> = []

     var stringList: [String] {
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
         self.title = titleForListType()
     }

     func titleForListType() -> String {
         switch healthProfile {
         case .preExistingCondition: return "Pre-Existing Conditions"
         case .intolerance: return "Intolerances"
         case .dietaryPreference: return "Dietary Preferences"
         case .none: return ""
         }
     }

     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return stringList.count
     }

     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "HealthDetailCell", for: indexPath)
         cell.textLabel?.text = stringList[indexPath.row]
         
         cell.accessoryType = selectedIndices.contains(indexPath.row) ? .checkmark : .none
         
         return cell
     }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if selectedIndices.contains(indexPath.row) {
            selectedIndices.remove(indexPath.row)
        } else {
            selectedIndices.insert(indexPath.row)
        }

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

}
