//

//  FoodDetailsViewController.swift

//  MomCare

//

//  Created by RITIK RANJAN on 07/06/25.

//

import SwiftUI

import UIKit

class FoodDetailsViewController: UIHostingController<FoodDetailsView> {

    // MARK: Lifecycle

    init(foodItem: FoodItem) {

        self.foodItem = foodItem

        super.init(rootView: FoodDetailsView(food: foodItem))

    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")

    }

    // MARK: Internal

    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        preferredContentSize = view.intrinsicContentSize

    }

    // MARK: Private

    private let foodItem: FoodItem

}
