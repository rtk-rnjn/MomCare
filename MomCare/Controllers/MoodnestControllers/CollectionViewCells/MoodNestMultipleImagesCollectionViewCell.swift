//
//  MoodNestMultipleImagesCollectionViewCell.swift
//  MomCare
//
//  Created by Batch - 2  on 18/01/25.
//

import UIKit

class MoodNestMultipleImagesCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageLabel: UILabel!

    func updateElements(image: UIImage?, label: String) {
        imageView.image = image
        imageLabel.text = label
    }
}
