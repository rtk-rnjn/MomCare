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

    func updateElements(with playlist: Playlist) {
        mainImageView.image = playlist.image
        mainImageLabel.text = playlist.name
    }
}
