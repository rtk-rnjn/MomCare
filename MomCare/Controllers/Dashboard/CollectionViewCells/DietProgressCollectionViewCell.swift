//
//  Section3CollectionViewCell.swift
//  MomCare
//
//  Created by Batch-2 on 15/01/25.
//

import UIKit

class DietProgressCollectionViewCell: UICollectionViewCell {

    @IBOutlet var currentKcalLabel: UILabel!
    @IBOutlet var caloriesGoalLabel: UILabel!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var percentageLabel: UILabel!
    
    func updateElements(with dietProgress: UserDiet) {
        currentKcalLabel.text = "\(dietProgress.plan.currentCaloriesIntake)"
        caloriesGoalLabel.text = "/ \(dietProgress.plan.caloriesGoal!) kcal"
        let progress = Float(dietProgress.plan.currentCaloriesIntake) / Float(dietProgress.plan.caloriesGoal!)
        progressBar.progress = progress
        percentageLabel.text = "\(Int(progress * 100))%"
    }
}
