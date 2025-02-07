//
//  ExerciseCollectionViewCell.swift
//  MomCare
//
//  Created by Nupur on 19/01/25.
//

import UIKit

class ExerciseCollectionViewCell: UICollectionViewCell {
    @IBOutlet var exerciseLevel: UILabel!
    @IBOutlet var exerciseName: UILabel!
    @IBOutlet var exerciseTime: UILabel!
    @IBOutlet var exerciseImage: UIImageView!
    @IBOutlet var exerciseCompletionPercentage: UILabel!
    @IBOutlet var exerciseStartButton: UIButton!
    var completedPercentage: Double = 0

    var segueHandler: (() -> Void)?
    var popUpHandler: (() -> Void)?

    @IBAction func startButtonTapped(_ sender: Any) {
        if let segueHandler {
            segueHandler()
        }
    }

    func updateElements(segueHandler handler: (() -> Void)? = nil, popUpHandler: (() -> Void)? = nil) {
        segueHandler = handler
        self.popUpHandler = popUpHandler
    }

    @IBAction func infoButtonTapped(_ sender: UIButton) {
        if let popUpHandler {
            popUpHandler()
        }
    }

}
