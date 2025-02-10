//
//  SongElementsViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 20/01/25.
//

import UIKit

class SongElementsViewController: UIViewController {

    @IBOutlet var playlistSongLabel: UILabel!
    @IBOutlet var playlistCoverImage: UIImageView!

    var playlist: Playlist?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateElements(with: playlist)
    }

    func updateElements(with playlist: Playlist?) {
        guard let playlist else { return }

        playlistSongLabel.text = playlist.name
        playlistCoverImage.image = playlist.image
    }
}
