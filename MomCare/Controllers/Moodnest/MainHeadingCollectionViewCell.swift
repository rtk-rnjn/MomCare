//
//  MainHeadingCollectionViewCell.swift
//  MomCare
//
//  Created by Batch - 2  on 18/01/25.
//

import UIKit

class MainHeadingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mainHeadingLabel: UILabel!
    
    func updateSection1(with indexPath: IndexPath) {
        mainHeadingLabel.text = "Take a moment to rewing with \"\(FeaturedPlaylists.playlists[indexPath.row].name)\" playlists"
    }
}
