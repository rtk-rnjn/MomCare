//
//  MealItemTableViewCell.swift
//  MomCare
//
//  Created by Aryan Singh on 17/01/25.
//

import UIKit

class MealItemTableViewCell: UITableViewCell {
    var foodImageName: String?
    var foodItemName: String?
    var foodServing: String?
    var foodKcal: String?
    var itemCheckBoxStatus: Bool?

    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var mealNameLabel: UILabel!
    @IBOutlet weak var servingLabel: UILabel!
    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var checkBoxButton: UIButton!
    
    func updateMealItemElements() {
        foodImageView.image = UIImage(named: foodImageName ?? "")
        mealNameLabel.text = foodItemName
        servingLabel.text = foodServing
        kcalLabel.text = foodKcal
        checkBoxButton.isSelected = itemCheckBoxStatus ?? false
    }

}
