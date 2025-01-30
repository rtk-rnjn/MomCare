//
//  SongPageTableViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 20/01/25.
//

import UIKit

class SongPageTableViewController: UITableViewController {
    var songs: [Song] = []
    var playlist: Playlist!

    @IBOutlet var moodNestTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        moodNestTableView.showsVerticalScrollIndicator = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        songs = playlist.songs
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongPageTableViewCell

        guard let cell else {
            fatalError("love is a fear of loss")
        }

        let song = songs[indexPath.row]
        cell.updateElements(with: song)

        return cell
    }

    @IBAction func unwindToSongPageViewController(_ segue: UIStoryboardSegue) {
    }
}
