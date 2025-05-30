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

    func updateElements(image: UIImage?, label: String) {
        sideImagesView.image = image
        sideImagesLabel.text = label
    }
}
