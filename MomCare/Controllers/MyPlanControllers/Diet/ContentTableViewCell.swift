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
        var consumed = false
        guard let indexPath, let dietTableViewController else { return }

        dietTableViewController.foodData[indexPath.section][indexPath.row - 1].consumed.toggle()
        consumed = dietTableViewController.foodData[indexPath.section][indexPath.row - 1].consumed

        let configuration = UIImage.SymbolConfiguration(scale: .small)

        DietViewController.addCalories(energy: Double(foodItem?.calories ?? 0), consumed: consumed)
        DietViewController.addCarbs(carbs: Double(foodItem?.carbs ?? 0), consumed: consumed)
        DietViewController.addProtein(protein: Double(foodItem?.protein ?? 0), consumed: consumed)
        DietViewController.addFats(fats: Double(foodItem?.fat ?? 0), consumed: consumed)

        if consumed {
            sender.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: configuration)?.withTintColor(color), for: .normal)
        } else {
            sender.setImage(UIImage(systemName: "circle", withConfiguration: configuration)?.withTintColor(color), for: .normal)
        }
        dietTableViewController.dietViewController.refresh()
    }

    // MARK: Private

    private var dietTableViewController: DietTableViewController?
    private let color: UIColor = .init(hex: "924350")
}
