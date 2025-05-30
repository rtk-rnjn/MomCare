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
    }
}
