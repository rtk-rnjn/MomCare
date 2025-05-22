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

    @IBOutlet var qualtityLabel: UILabel!
    @IBOutlet var foodItemLabel: UILabel!
    @IBOutlet var kalcLabel: UILabel!
    @IBOutlet var foodImageView: UIImageView!

    @IBOutlet var foodItemButton: UIButton!

    var foodItem: FoodItem?

    var buttonTapHandler: (() -> Bool)?
    var refreshHandler: (() -> Void)?

    func updateElements(with foodItem: FoodItem, refreshHandler: (() -> Void)? = nil, buttonTapHandler: @escaping (() -> Bool)) {
        foodItemLabel.text = foodItem.name
        kalcLabel.text = "\(String(foodItem.calories)) cal."
        Task {
            let image = await foodItem.image
            DispatchQueue.main.async {
                self.foodImageView.image = image
            }
        }
        self.foodItem = foodItem

        self.buttonTapHandler = buttonTapHandler
        self.refreshHandler = refreshHandler

        let consumed = foodItem.consumed

        let configuration = UIImage.SymbolConfiguration(scale: .small)

        if consumed {
            foodItemButton.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: configuration)?.withTintColor(color), for: .normal)
        } else {
            foodItemButton.setImage(UIImage(systemName: "circle", withConfiguration: configuration)?.withTintColor(color), for: .normal)
        }
    }

    @IBAction func foodItemButtonTapped(_ sender: UIButton) {
        guard let buttonTapHandler else { return }

        let consumed = buttonTapHandler()

        DietViewController.addCalories(energy: Double(foodItem?.calories ?? 0), consumed: consumed)
        DietViewController.addCarbs(carbs: Double(foodItem?.carbs ?? 0), consumed: consumed)
        DietViewController.addProtein(protein: Double(foodItem?.protein ?? 0), consumed: consumed)
        DietViewController.addFats(fats: Double(foodItem?.fat ?? 0), consumed: consumed)

        refreshHandler?()
    }

    // MARK: Private

    private let color: UIColor = .init(hex: "924350")
}
