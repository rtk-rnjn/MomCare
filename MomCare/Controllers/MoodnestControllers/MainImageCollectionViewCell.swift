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

    func updateSection2(with indexPath: IndexPath) {

        mainImageView.image = FeaturedPlaylists.playlists[indexPath.row].image

        mainImageLabel.text = FeaturedPlaylists.playlists[indexPath.row].name

    }

}
