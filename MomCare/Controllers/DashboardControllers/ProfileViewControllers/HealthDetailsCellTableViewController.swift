//
//  HealthDetailsCellTableViewController.swift
//  MomCare
//
//  Created by Nupur on 13/06/25.
//

import UIKit

class HealthDetailsCellTableViewController: UITableViewController {

    var healthProfile: HealthProfileType?
    var selectedCells: [String] = []

    var onSelection: ((HealthProfileType, [String]) -> Void)?

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
        title = healthListtitle()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        guard let profile = healthProfile else { return }
        onSelection?(profile, selectedCells)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return healthList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HealthDetailCell", for: indexPath)

        let item = healthList[indexPath.row]
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = item
        cell.accessoryType = selectedCells.contains(item) ? .checkmark : .none
        cell.contentConfiguration = contentConfig

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = healthList[indexPath.row]

        if selectedCells.contains(item) {
            selectedCells.removeAll { $0 == item }
        } else {
            selectedCells.append(item)
        }

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func healthListtitle() -> String {
        switch healthProfile {
        case .preExistingCondition: return "Pre-Existing Conditions"
        case .intolerance: return "Intolerances"
        case .dietaryPreference: return "Dietary Preferences"
        case .none: return ""
        }
    }

}
