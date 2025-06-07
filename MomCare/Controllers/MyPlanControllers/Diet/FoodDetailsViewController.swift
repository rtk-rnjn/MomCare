//
//  FoodDetailsViewController.swift
//  MomCare
//
//  Created by RITIK RANJAN on 07/06/25.
//

import SwiftUI
import UIKit

class FoodDetailsViewController: UIHostingController<FoodDetailsView> {
    private let foodItem: FoodItem

    init(foodItem: FoodItem) {
        self.foodItem = foodItem
        super.init(rootView: FoodDetailsView(food: foodItem))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = view.intrinsicContentSize
    }
}
