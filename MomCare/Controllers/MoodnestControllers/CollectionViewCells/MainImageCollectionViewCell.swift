//
//  MainImageCollectionViewCell.swift
//  MomCare
//
//  Created by Batch - 2  on 18/01/25.
//

import UIKit

class MainImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var mainImageLabel: UILabel!

    func updateElements(image: UIImage?, label: String) {
        mainImageView.image = image
        mainImageLabel.text = label
        mainImageLabel.accessibilityLabel = "Album Name: \(mainImageLabel.text ?? "Unknown")"
        mainImageLabel.accessibilityHint = "Your current Playlist name"
        mainImageView.accessibilityLabel = "Album artwork for \(mainImageLabel.text ?? "Unknown")"
        mainImageView.accessibilityHint = "Represents the cover image for the current Playlist"
    }
}
