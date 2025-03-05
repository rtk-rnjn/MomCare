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

    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard let foodItem else { return }
        confirmAlert(title: "Add Food", message: "Do you want to add \(foodItem.name) to your meal?", with: sender)
    }

    func updateElements(with foodItem: FoodItem, sender viewController: SearchViewController?) {
        foodImageView.image = foodItem.image
        foodLabel.text = foodItem.name
        foodMetadata.text = "\(foodItem.calories) calories"

        self.foodItem = foodItem
        self.viewController = viewController
    }

    // MARK: Private

    private func confirmAlert(title: String, message: String, with button: UIButton) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: alertConfirmTapped)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: alertCancelTapped)

        alert.addAction(confirmAction)
        alert.addAction(cancelAction)

        viewController?.present(alert, animated: true, completion: nil)
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

        viewController?.dismiss(animated: true) {
            self.viewController?.refreshHandler?()
        }

    }

    private func alertCancelTapped(_ actionAlert: UIAlertAction) {
        print("Cancel Tapped")
    }
}
