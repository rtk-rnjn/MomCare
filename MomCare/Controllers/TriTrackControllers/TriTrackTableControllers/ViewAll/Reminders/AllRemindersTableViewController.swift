//
//  AllRemindersTableViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 20/01/25.
//

import UIKit

class AllRemindersTableViewController: UITableViewController {
    
    var reminders: [TriTrackReminder] = []

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllRemindersTableViewCell", for: indexPath) as? AllRemindersTableViewCell
        
        guard let cell = cell else { fatalError() }
        
        cell.updateElements(with: reminders[indexPath.row])

        return cell
    }

}
