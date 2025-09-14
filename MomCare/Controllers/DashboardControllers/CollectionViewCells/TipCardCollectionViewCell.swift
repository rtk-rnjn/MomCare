//
//  TipCardCollectionViewCell.swift
//  MomCare
//
//  Created by Batch-2 on 16/01/25.
//

import UIKit

class TipCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet var currentTipLabel: UILabel!

    func updateElements(with tip: Tip) {
        currentTipLabel.text = tip.dailyTip
        
        // Set up accessibility
        currentTipLabel.accessibilityLabel = "Daily tip"
        currentTipLabel.accessibilityValue = tip.dailyTip
        currentTipLabel.accessibilityTraits = .staticText
        
        // Enable automatic font sizing for Dynamic Type
        currentTipLabel.adjustsFontForContentSizeCategory = true
        currentTipLabel.font = UIFont.preferredFont(forTextStyle: .body)
    }

}
