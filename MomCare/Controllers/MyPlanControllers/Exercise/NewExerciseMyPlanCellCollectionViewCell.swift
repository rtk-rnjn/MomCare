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
