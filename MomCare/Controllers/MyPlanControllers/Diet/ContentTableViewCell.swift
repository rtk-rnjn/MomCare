//
//  ContentTableViewCell.swift
//  MomCare
//
//  Created by Batch - 2  on 20/01/25.
//

import UIKit

class ContentTableViewCell: UITableViewCell {

    // MARK: Internal

    @IBOutlet var qualtityLabel: UILabel!
    @IBOutlet var foodItemLabel: UILabel!
    @IBOutlet var kalcLabel: UILabel!
    @IBOutlet var foodImageView: UIImageView!

    @IBOutlet var foodItemButton: UIButton!

    var foodItem: FoodItem?
    var indexPath: IndexPath?

    func updateElements(with foodItem: FoodItem, at indexPath: IndexPath?, of view: DietTableViewController) {
        foodItemLabel.text = foodItem.name
        kalcLabel.text = "\(String(foodItem.calories)) cal."
        foodImageView.image = foodItem.image

        self.foodItem = foodItem
        self.indexPath = indexPath

        dietTableViewController = view
    }

    @IBAction func foodItemButtonTapped(_ sender: UIButton) {
        var consumed: Bool
        switch indexPath?.section {
        // fix: cases <Int> should be replaced with MealType enum cases
        case 0:
            consumed = MomCareUser.shared.markFoodAsConsumed(foodItem!, in: MealType.breakfast)
        case 1:
            consumed = MomCareUser.shared.markFoodAsConsumed(foodItem!, in: MealType.lunch)
        case 2:
            consumed = MomCareUser.shared.markFoodAsConsumed(foodItem!, in: MealType.snacks)
        case 3:
            consumed = MomCareUser.shared.markFoodAsConsumed(foodItem!, in: MealType.dinner)
        default:
            fatalError()
        }
        let configuration = UIImage.SymbolConfiguration(scale: .small)
        if consumed {
            sender.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: configuration)?.withTintColor(color), for: .normal)
        } else {
            sender.setImage(UIImage(systemName: "circle", withConfiguration: configuration)?.withTintColor(color), for: .normal)
        }
        dietTableViewController?.dietViewController.refresh()
    }

    // MARK: Private

    private var dietTableViewController: DietTableViewController?

    private let color: UIColor = UIColor(hex: "924350")

}
