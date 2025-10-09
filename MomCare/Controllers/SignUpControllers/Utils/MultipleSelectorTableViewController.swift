//
//  MultipleSelectorTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 14/02/25.
//

import UIKit

class MultipleSelectorTableViewController: UITableViewController {
    var options: [String] = .init()
    var selectedMappedOptions: [String: Bool] = [:]
    var dismissHandler: (() -> Void)?

    var preViewDidLoad: ((UIViewController) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        if selectedMappedOptions.isEmpty {
            selectedMappedOptions = options.reduce(into: [:]) { $0[$1] = false }
        }
        if preViewDidLoad != nil {
            preViewDidLoad?(self)
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        }

        tableView.reloadData()
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

        let option = options[indexPath.row]
        let isSelected = selectedMappedOptions[option] ?? false
        cell.accessoryType = isSelected ? .checkmark : .none
        cell.contentConfiguration = contentConfig
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let option = selectedMappedOptions[options[indexPath.row]] {
            selectedMappedOptions[options[indexPath.row]] = !option
        } else {
            let option = options[indexPath.row]
            selectedMappedOptions[option] = true
        }

        tableView.reloadRows(at: [indexPath], with: .fade)
    }

    @objc func cancelTapped() {
        dismiss(animated: true) {
            self.dismissHandler?()
        }
    }

}
