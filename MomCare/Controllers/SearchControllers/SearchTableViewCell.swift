//
//  SearchTableViewCell.swift
//  MomCare
//
//  Created by Ritik Ranjan on 31/01/25.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet var foodImageView: UIImageView!
    @IBOutlet var foodLabel: UILabel!
    @IBOutlet var foodMetadata: UILabel!
    
    var viewController: UIViewController?
    var foodItem: FoodItem?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard let foodItem else { return }
        confirmAlert(title: "Add Food", message: "Do you want to add \(foodItem.name) to your meal?", with: sender)
    }
    
    func updateElements(with foodItem: FoodItem, sender viewController: UIViewController?) {
        foodImageView.image = foodItem.image
        foodLabel.text = foodItem.name
        foodMetadata.text = "\(foodItem.calories) calories"
        
        self.foodItem = foodItem
        self.viewController = viewController
    }
    
    private func confirmAlert(title: String, message: String, with button: UIButton) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: alertConfirmTapped)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: alertCancelTapped)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    private func alertConfirmTapped(_ actionAlert: UIAlertAction) {
        print("Confirm Tapped")
    }
    
    private func alertCancelTapped(_ actionAlert: UIAlertAction) {
        print("Cancel Tapped")
    }
}
