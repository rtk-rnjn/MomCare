//
//  SearchTableViewCell.swift
//  MomCare
//
//  Created by Ritik Ranjan on 31/01/25.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    // MARK: Internal

    @IBOutlet var foodImageView: UIImageView!
    @IBOutlet var foodLabel: UILabel!
    @IBOutlet var foodMetadata: UILabel!

    var viewController: SearchViewController?
    var foodItem: FoodItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAccessibility()
    }
    
    private func setupAccessibility() {
        // Configure labels with Dynamic Type
        foodLabel.enableDynamicType()
        foodLabel.setupInformationalAccessibility(importance: .high)
        
        foodMetadata.enableDynamicType()
        foodMetadata.setupInformationalAccessibility(importance: .medium)
        
        // Configure image view as decorative initially (will be updated with actual content)
        foodImageView.isAccessibilityElement = false
        foodImageView.accessibilityElementsHidden = true
        
        // Make the entire cell accessible
        isAccessibilityElement = true
        accessibilityTraits = [.button]
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard let foodItem else { return }
        confirmAlert(title: "Add Food", message: "Do you want to add \(foodItem.name) to your meal?", with: sender)
    }

    func updateElements(with foodItem: FoodItem, sender viewController: SearchViewController?) {
        Task {
            foodImageView.image = await foodItem.image
        }
        foodLabel.text = foodItem.name
        foodMetadata.text = "\(foodItem.calories) calories"

        self.foodItem = foodItem
        self.viewController = viewController
        
        // Update accessibility when content changes
        updateAccessibilityContent(foodItem: foodItem)
    }
    
    private func updateAccessibilityContent(foodItem: FoodItem) {
        // Update accessibility label with food information
        accessibilityLabel = "\(foodItem.name), \(foodItem.calories) calories"
        accessibilityHint = "Tap to add this food item to your meal"
        
        // Update image accessibility if needed
        if foodImageView.image != nil {
            foodImageView.isAccessibilityElement = false // Keep it decorative
        }
    }

    // MARK: Private

    private func confirmAlert(title: String, message: String, with button: UIButton) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: alertConfirmTapped)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: alertCancelTapped)

        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        // Configure alert accessibility
        UIKitAccessibilityHelper.configureAlertController(alert)

        viewController?.present(alert, animated: true)
    }

    private func alertConfirmTapped(_ actionAlert: UIAlertAction) {
        guard let foodItem else { return }

        switch viewController?.mealName {
        case "Breakfast":
            MomCareUser.shared.user?.plan.breakfast.append(foodItem)
        case "Lunch":
            MomCareUser.shared.user?.plan.lunch.append(foodItem)
        case "Snacks":
            MomCareUser.shared.user?.plan.snacks.append(foodItem)
        case "Dinner":
            MomCareUser.shared.user?.plan.dinner.append(foodItem)
        default:
            break
        }

        viewController?.searchBarController.dismiss(animated: true) {
            self.viewController?.dismiss(animated: true) {
                self.viewController?.completionHandlerOnFoodItemAdd?()
            }
        }
    }

    private func alertCancelTapped(_ actionAlert: UIAlertAction) {}
}
