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
        currentTipLabel.accessibilityLabel = tip.dailyTip
        currentTipLabel.accessibilityHint = "Daily health tip for your pregnancy"
        currentTipLabel.font = UIFont.preferredFont(forTextStyle: .body)
        currentTipLabel.adjustsFontForContentSizeCategory = true
        
        isAccessibilityElement = true
        accessibilityLabel = "Daily tip: \(tip.dailyTip)"
        accessibilityHint = "Daily health tip for your pregnancy"
        accessibilityTraits = .staticText
    }

}
