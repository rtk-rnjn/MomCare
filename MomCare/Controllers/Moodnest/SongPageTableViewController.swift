//
//  SongPageTableViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 20/01/25.
//

import UIKit

class SongPageTableViewController: UITableViewController {
    var data: [Song] = FeaturedPlaylists.playlists[0].songs

    @IBOutlet var moodNestTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        moodNestTableView.showsVerticalScrollIndicator = false
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongPageTableViewCell
        
        guard let cell = cell else {
            fatalError("What is love?")
        }
        
        let song = self.data[indexPath.row]
        cell.updateElement(with: song)

        return cell
    }

}
