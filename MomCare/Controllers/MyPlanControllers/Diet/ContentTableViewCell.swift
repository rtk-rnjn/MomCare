//
//  ContentTableViewCell.swift
//  MomCare
//
//  Created by Batch - 2  on 20/01/25.
//

import UIKit

class ContentTableViewCell: UITableViewCell {

    @IBOutlet var qualtityLabel: UILabel!
    @IBOutlet var foodItemLabel: UILabel!
    @IBOutlet var kalcLabel: UILabel!
    @IBOutlet var foodImageView: UIImageView!
    
    @IBOutlet var foodItemButton: UIButton!

    var foodItem: FoodItem?
    var indexPath: IndexPath?
    
    private var dietTableViewController: DietTableViewController?
    
    private let color = Converters.convertHexToUIColor(hex: "924350")

    func updateElements(with foodItem: FoodItem, at indexPath: IndexPath?, of view: DietTableViewController) {
        foodItemLabel.text = foodItem.name
        kalcLabel.text = "\(String(foodItem.calories)) cal."
        foodImageView.image = foodItem.image

        self.foodItem = foodItem
        self.indexPath = indexPath
        
        self.dietTableViewController = view
    }

    @IBAction func foodItemButtonTapped(_ sender: UIButton) {
        switch self.indexPath?.section {
        case 0:
            MomCareUser.shared.diet.markFoodAsConsumed(self.foodItem!, in: MealType.breakfast)
        case 1:
            MomCareUser.shared.diet.markFoodAsConsumed(self.foodItem!, in: MealType.lunch)
        case 2:
            MomCareUser.shared.diet.markFoodAsConsumed(self.foodItem!, in: MealType.snacks)
        case 3:
            MomCareUser.shared.diet.markFoodAsConsumed(self.foodItem!, in: MealType.dinner)
        default:
            break
        }
        let configuration = UIImage.SymbolConfiguration(scale: .small)
        foodItemButton.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: configuration)?.withTintColor(color), for: .normal)
        dietTableViewController?.dietViewController.refresh()
    }
}
