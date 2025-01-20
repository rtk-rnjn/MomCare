//
//  AllRemindersTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 20/01/25.
//

import UIKit

class AllRemindersTableViewController: UITableViewController {
    
    var data: [TriTrackReminder] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.data = MomCareUser.shared.reminders
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }

}
