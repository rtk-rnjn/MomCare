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

    var segueHandler: (() -> Void)?
    var popUpHandler: ((Exercise?) -> Void)?
    var exercise: Exercise?

    @IBAction func startButtonTapped(_ sender: Any) {
        if let segueHandler {
            segueHandler()
        }
    }

    @IBAction func infoButtonTapped(_ sender: UIButton) {
        if let popUpHandler {
            popUpHandler(exercise)
        }
    }

    func updateElements(with exercise: Exercise, segueHandler handler: (() -> Void)? = nil, popUpHandler: ((Exercise?) -> Void)? = nil) {
        segueHandler = handler
        self.popUpHandler = popUpHandler
        self.exercise = exercise
    }

}
