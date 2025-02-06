//
//  NewExerciseMyPlanCellCollectionViewCell.swift
//  MomCare
//
//  Created by Nupur on 19/01/25.
//

import UIKit

protocol NewExerciseMyPlanCellDelegate: AnyObject {
    func didTapInfoButton()
}

class NewExerciseMyPlanCellCollectionViewCell: UICollectionViewCell {
    @IBOutlet var exerciseLevel: UILabel!
    @IBOutlet var exerciseName: UILabel!
    @IBOutlet var exerciseTime: UILabel!
    @IBOutlet var exerciseImage: UIImageView!
    @IBOutlet var exerciseCompletionPercentage: UILabel!
    @IBOutlet var exerciseStartButton: UIButton!
    @IBOutlet var infoButton: UIButton!
    @IBOutlet var dimmedBackgroundView: UIView!
    
    var completedPercentage: Double = 0
    var segueHandler: (() -> Void)?
    weak var delegate: NewExerciseMyPlanCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
    }

    @IBAction func startButtonTapped(_ sender: Any) {
        if let segueHandler {
            segueHandler()
        }
    }

    func updateElements(with handler: (() -> Void)?) {
        segueHandler = handler
    }
    
    @objc func infoButtonTapped(_ sender: UIButton) {
        delegate?.didTapInfoButton()
    }
}
