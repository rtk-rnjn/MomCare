//
//  NewExerciseMyPlanCellCollectionViewCell.swift
//  MomCare
//
//  Created by Nupur on 19/01/25.
//

import UIKit

class NewExerciseMyPlanCellCollectionViewCell: UICollectionViewCell {
    @IBOutlet var exerciseLevel: UILabel!
    @IBOutlet var exerciseName: UILabel!
    @IBOutlet var exerciseTime: UILabel!
    @IBOutlet var exerciseImage: UIImageView!
    @IBOutlet var exerciseCompletionPercentage: UILabel!
    @IBOutlet var exerciseStartButton: UIButton!
    var completedPercentage: Double = 0
    
    var segueHandler: (() -> Void)?

    @IBAction func startButtonTapped(_ sender: Any) {
        
        if let segueHandler = segueHandler {
            segueHandler()
        }
    }
    
    func updateElements(with handler: (() -> Void)?) {
        self.segueHandler = handler
    }    
}


