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

    var segueHandler: (() -> Void)?
    var popUpHandler: ((Exercise?) -> Void)?
    var exercise: Exercise?

    @IBAction func breathingStartButtonTapped(_ sender: Any) {
        if let segueHandler {
            segueHandler()
        }
    }

    func updateElements(with exercise: Exercise, segueHandler handler: (() -> Void)? = nil, popUpHandler: ((Exercise?) -> Void)? = nil) {
        segueHandler = handler
        self.popUpHandler = popUpHandler
        self.exercise = exercise
    }

    @IBAction func breathingInfoButtonTapped(_ sender: Any) {
        if let popUpHandler {
            popUpHandler(exercise)
        }
    }

}
