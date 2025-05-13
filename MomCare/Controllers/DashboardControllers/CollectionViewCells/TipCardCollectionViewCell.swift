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
    }

}
