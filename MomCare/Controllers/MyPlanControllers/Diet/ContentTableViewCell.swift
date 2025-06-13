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
        Task {
            let image = await foodItem.image
            DispatchQueue.main.async {
                self.foodImageView.image = image
            }
        }
        self.foodItem = foodItem
        self.buttonTapHandler = buttonTapHandler
        self.servingLabel.text = foodItem.serving
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
