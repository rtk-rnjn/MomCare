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

    func updateElements(with exercise: Exercise, popUpHandler: ((Exercise?) -> Void)? = nil, segueHandler handler: (() -> Void)? = nil) {
        segueHandler = handler
        self.popUpHandler = popUpHandler
        self.exercise = exercise

        exerciseName.text = "Exercise: \(exercise.name)"
        if exercise.duration != nil {
            exerciseTime.isHidden = false
            exerciseTime.text = exercise.humanReadableDuration
            exerciseStartButton.setTitle("Resume", for: .normal)
        } else {
            exerciseTime.isHidden = true
            exerciseStartButton.setTitle("Start", for: .normal)
        }

        exerciseCompletionPercentage.text = "\(exercise.completionPercentage)% completed"
        exerciseLevel.text = exercise.level.rawValue.capitalized
    }

}
