//
//  PlaylistCollectionViewCell.swift
//  MomCare
//
//  Created by Batch - 2  on 18/01/25.
//

import UIKit

class PlaylistCollectionViewCell: UICollectionViewCell {

    // MARK: Internal

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var playlistLabel: UILabel!

    var playlist: (imageUri: String, label: String)?

    func updateElements(with playlist: (imageUri: String, label: String)?, applyLargeTitle: Bool = false) {
        guard let playlist else { return }
        self.playlist = playlist
        Task {
            await updateUI(with: playlist.imageUri, label: playlist.label, applyLargeTitle: applyLargeTitle)
        }
    }

    // MARK: Private

    private func updateUI(with imageUri: String, label: String, applyLargeTitle: Bool) async {
        imageView.image = await UIImage().fetchImage(from: imageUri)
        imageView.accessibilityLabel = "Album artwork for \(label)"
        imageView.accessibilityHint = "Cover image for the playlist"

        playlistLabel.text = label
        if applyLargeTitle {
            playlistLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        } else {
            playlistLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        }
        playlistLabel.adjustsFontForContentSizeCategory = true

        playlistLabel.accessibilityLabel = label
        
        // Configure cell as accessible element
        self.isAccessibilityElement = true
        self.accessibilityLabel = "Playlist: \(label)"
        self.accessibilityHint = "Double tap to play this playlist"
        self.accessibilityTraits = .button
    }
}
