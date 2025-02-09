//
//  MoodNestMultipleImagesCollectionViewCell.swift
//  MomCare
//
//  Created by Batch - 2  on 18/01/25.
//

import UIKit

class MoodNestMultipleImagesCollectionViewCell: UICollectionViewCell {
    @IBOutlet var sideImagesView: UIImageView!
    @IBOutlet var sideImagesLabel: UILabel!

    func updateElements(with playlist: Playlist) {
        sideImagesView.image = playlist.image
        sideImagesLabel.text = playlist.name
    }
}
