//
//  MealHeaderTableViewCell.swift
//  MomCare
//
//  Created by Aryan Singh on 17/01/25.
//

import UIKit

class MealHeaderTableViewCell: UITableViewCell {
    
    var mealHeader: String?
    var headerCheckBox: Bool?
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        if headerLabel == nil {
                    fatalError("headerLabel outlet is not connected properly!")
                }
        // Initialization code
    }

}
