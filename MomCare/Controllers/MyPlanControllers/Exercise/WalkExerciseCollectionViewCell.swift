//
//  WalkExerciseCollectionViewCell.swift
//  MomCare
//
//  Created by Nupur on 19/01/25.
//

import UIKit

class WalkExerciseCollectionViewCell: UICollectionViewCell {

    @IBOutlet var completionPercentageLabel: UILabel!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var stepsLabel: UILabel!
    @IBOutlet var stepsGoalLabel: UILabel!

    var steps: Double = 0
    var stepsGoal: Double = 1200
    var completionPercentage: Double = 0

    func updateElements() {
        stepsLabel.text = "\(Int(steps)) Steps"
        stepsGoalLabel.text = "Goal: \(Int(stepsGoal)) Steps"
        completionPercentageLabel.text = "\(completionPercentage)% Completed"

        let progress = steps / stepsGoal
        progressView.setProgress(Float(progress), animated: true)
    }
}
