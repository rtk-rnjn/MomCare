//
//  FacesCollectionViewCell.swift
//  MomCare
//
//  Created by Batch - 2  on 16/01/25.
//

import UIKit

class FacesCollectionViewCell: UICollectionViewCell {

    @IBOutlet var faceImageView: UIImageView!
    @IBOutlet var moodLabel: UILabel!

    func setup(with mood: Mood) {
        faceImageView.image = mood.image
        moodLabel.text = mood.type.rawValue
    }
}
