//
//  MoodnestMultipleImagesCollectionViewCell.swift
//  MomCare
//
//  Created by Batch - 2  on 18/01/25.
//

import UIKit

class MoodNestMultipleImagesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var sideImagesView: UIImageView!
    @IBOutlet weak var sideImagesLabel: UILabel!
    
    func updateSection3(with indexPath: IndexPath){
        sideImagesView.image = FeaturedPlaylists.playlists[indexPath.row].image
        sideImagesLabel.text = FeaturedPlaylists.playlists[indexPath.row].name
    }
}
