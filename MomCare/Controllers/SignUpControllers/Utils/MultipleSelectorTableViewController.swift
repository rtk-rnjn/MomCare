//
//  MultipleSelectorTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 14/02/25.
//

import UIKit

class MultipleSelectorTableViewController: UITableViewController {
    var options: [String] = []
    var selectedMappedOptions: [String: Bool] = [:]
    var dismissHandler: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedMappedOptions = options.reduce(into: [:]) { $0[$1] = false }
    }

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

        cell.accessoryType = selectedMappedOptions[options[indexPath.row]]! ? .checkmark : .none
        cell.contentConfiguration = contentConfig
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMappedOptions[options[indexPath.row]] = !selectedMappedOptions[options[indexPath.row]]!
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
}
