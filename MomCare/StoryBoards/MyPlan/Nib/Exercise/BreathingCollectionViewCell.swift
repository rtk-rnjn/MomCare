//
//  BreathingCollectionViewCell.swift
//  MomCare
//
//  Created by Nupur on 16/02/25.
//

import UIKit

class BreathingCollectionViewCell: UICollectionViewCell {

    @IBOutlet var breathingExerciseName: UILabel!
    @IBOutlet var breathingTime: UILabel!
    @IBOutlet var breathingImage: UIImageView!
    @IBOutlet var breathingStartButton: UIButton!
    var completedPercentage: Double = 0

    var segueHandler: (() -> Void)?
    var popUpHandler: (() -> Void)?

    @IBAction func breathingStartButtonTapped(_ sender: Any) {
        if let segueHandler {
            segueHandler()
        }
    }

    func updateElements(segueHandler handler: (() -> Void)? = nil, popUpHandler: (() -> Void)? = nil) {
        segueHandler = handler
        self.popUpHandler = popUpHandler
    }

    @IBAction func breathingInfoButtonTapped(_ sender: Any) {
        if let popUpHandler {
            popUpHandler()
        }
    }

}
