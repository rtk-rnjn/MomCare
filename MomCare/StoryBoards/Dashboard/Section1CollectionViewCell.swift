//
//  Section1CollectionViewCell.swift
//  MomCare
//
//  Created by Batch-2 on 15/01/25.
//

import UIKit

class Section1CollectionViewCell: UICollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 16
        self.contentView.layer.masksToBounds = true
    }
}
