//

//  DashboardSectionHeaderCollectionViewCell.swift

//  MomCare

//

//  Created by Batch-2 on 17/01/25.

//

import UIKit

class DashboardSectionHeaderCollectionViewCell: UICollectionViewCell {

    @IBOutlet var titleLabel: UILabel!

    func updateElements(with title: String) {

        titleLabel.text = title

    }

}
