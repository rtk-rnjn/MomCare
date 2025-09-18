//
//  ContentTableViewCell.swift
//  MomCare
//
//  Created by Batch - 2  on 20/01/25.
//

import UIKit
import HealthKit

class ContentTableViewCell: UITableViewCell {

    // MARK: Internal

    var dietViewController: DietViewController?
    var refreshHandler: (() -> Void)?

    @IBOutlet var qualtityLabel: UILabel!
    @IBOutlet var foodItemLabel: UILabel!
    @IBOutlet var kalcLabel: UILabel!
    @IBOutlet var foodImageView: UIImageView!
    @IBOutlet var literalDotImageView: UIImageView!
    @IBOutlet var servingLabel: UILabel!

    @IBOutlet var foodItemButton: UIButton!

    var foodItem: FoodItem?

    var buttonTapHandler: (() -> Bool)?

    func updateElements(with foodItem: FoodItem, buttonTapHandler: @escaping (() -> Bool)) {
        foodItemLabel.text = foodItem.name
        kalcLabel.text = "\(String(foodItem.calories)) cal."
        
        // Apply Dynamic Type support
        foodItemLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        foodItemLabel.adjustsFontForContentSizeCategory = true
        
        kalcLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        kalcLabel.adjustsFontForContentSizeCategory = true
        
        servingLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        servingLabel.adjustsFontForContentSizeCategory = true
        
        Task {
            let image = await foodItem.image
            DispatchQueue.main.async {
                self.foodImageView.image = image
                self.foodImageView.accessibilityLabel = "Food image for \(foodItem.name)"
            }
        }
        self.foodItem = foodItem
        self.buttonTapHandler = buttonTapHandler
        servingLabel.text = foodItem.serving
        let consumed = foodItem.consumed

        let configuration = UIImage.SymbolConfiguration(scale: .small)

        if consumed {
            foodItemButton.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: configuration)?.withTintColor(color), for: .normal)
            foodItemButton.accessibilityLabel = "Mark as not consumed"
            foodItemButton.accessibilityValue = "Currently marked as consumed"
        } else {
            foodItemButton.setImage(UIImage(systemName: "circle", withConfiguration: configuration)?.withTintColor(color), for: .normal)
            foodItemButton.accessibilityLabel = "Mark as consumed"
            foodItemButton.accessibilityValue = "Currently not consumed"
        }
        
        foodItemButton.accessibilityHint = "Toggles consumption status of this food item"
        foodItemButton.accessibilityTraits = .button
        
        // Ensure minimum touch target size
        foodItemButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        foodItemButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        
        // Set up accessibility for labels
        foodItemLabel.accessibilityLabel = "Food item: \(foodItem.name)"
        kalcLabel.accessibilityLabel = "\(foodItem.calories) calories"
        servingLabel.accessibilityLabel = "Serving size: \(foodItem.serving)"
        
        // Configure cell accessibility
        accessibilityElements = [foodItemLabel!, kalcLabel!, servingLabel!, foodItemButton!]
        isAccessibilityElement = false
    }

    @IBAction func foodItemButtonTapped(_ sender: UIButton) {
        guard let buttonTapHandler else { return }

        let consumed = buttonTapHandler()

        Task {
            await self.dietViewController?.addCalories(energy: Double(foodItem?.calories ?? 0), consumed: consumed)
            await self.dietViewController?.addCarbs(carbs: Double(foodItem?.carbs ?? 0), consumed: consumed)
            await self.dietViewController?.addProtein(protein: Double(foodItem?.protein ?? 0), consumed: consumed)
            await self.dietViewController?.addFats(fats: Double(foodItem?.fat ?? 0), consumed: consumed)

            DispatchQueue.main.async {
                self.refreshHandler?()
            }
        }
    }

    // MARK: Private

    private let color: UIColor = .init(hex: "924350")
}
