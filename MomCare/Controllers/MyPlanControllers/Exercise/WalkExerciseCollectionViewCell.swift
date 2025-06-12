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
    var stepsGoal: Double = Utils.getStepGoal(week: MomCareUser.shared.user?.pregancyData?.week ?? 1)

    func updateElements() {
        stepsLabel.text = "\(Int(steps)) Steps"
        stepsGoalLabel.text = "Goal: \(Int(stepsGoal)) Steps"
        let completionPercentage = Int((steps / stepsGoal) * 100)
        let boundedCompletionPercentage = min(max(completionPercentage, 0), 100)
        completionPercentageLabel.text = "\(boundedCompletionPercentage)% Completed"

        let progress = steps / stepsGoal
        progressView.setProgress(Float(progress), animated: true)
    }
}
