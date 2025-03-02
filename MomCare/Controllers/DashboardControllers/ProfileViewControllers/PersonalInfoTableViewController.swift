//
//  PersonalInfoTableViewController.swift
//  MomCare
//
//  Created by Khushi Rana on 02/03/25.
//

import UIKit

class PersonalInfoTableViewController: UITableViewController {
    var name: String? = " "
    var age: String? = " "
    var dob: String? = " "
    var height: String? = " "
    var currentWeight: String? = " "
    var weeksPregnant: String? = " "
    var prePregnancyWeight: String? = " "
    var trimester: String? = " "

    var isEditingMode = false

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEditMode))
    }

        @objc func toggleEditMode() {
        isEditingMode.toggle()

        navigationItem.rightBarButtonItem?.title = isEditingMode ? "Save" : "Edit"

        tableView.reloadData()
    }

}
