//
//  FocusCardCollectionViewCell.swift
//  MomCare
//
//  Created by Batch-2 on 16/01/25.
//

import UIKit

class FocusCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet var currentFocusLabel: UILabel!

    func updateElements(with tip: Tip) {
        currentFocusLabel.text = tip.todaysFocus
        currentFocusLabel.accessibilityLabel = tip.todaysFocus
        currentFocusLabel.accessibilityHint = "Today's focus tip for your pregnancy journey"
        currentFocusLabel.font = UIFont.preferredFont(forTextStyle: .body)
        currentFocusLabel.adjustsFontForContentSizeCategory = true
        
        isAccessibilityElement = true
        accessibilityLabel = "Focus tip: \(tip.todaysFocus)"
        accessibilityHint = "Today's focus tip for your pregnancy journey"
        accessibilityTraits = .staticText
    }
}
