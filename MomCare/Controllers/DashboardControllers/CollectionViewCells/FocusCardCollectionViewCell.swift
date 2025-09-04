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

    }

}
