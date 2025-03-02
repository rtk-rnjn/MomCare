//
//  SongElementsViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 20/01/25.
//

import UIKit

class SongElementsViewController: UIViewController {

    // MARK: Internal

    @IBOutlet var playlistSongLabel: UILabel!
    @IBOutlet var playlistCoverImage: UIImageView!

    var playlist: Playlist?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateElements(with: playlist)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addGradient()
    }

    // MARK: Private

    private func updateElements(with playlist: Playlist?) {
        guard let playlist else { return }

        playlistSongLabel.text = playlist.name
        playlistCoverImage.image = playlist.image
    }

    // https://discord.com/channels/1283435123232079933/1285117124041244765/1334221772609945730
    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(
            x: 0,
            y: playlistCoverImage.frame.height / 2,
            width: playlistCoverImage.frame.width,
            height: playlistCoverImage.frame.height / 2
        )

        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.cgColor
        ]

        gradientLayer.locations = [0.0, 1.0]

        playlistCoverImage.layer.addSublayer(gradientLayer)
    }
}
