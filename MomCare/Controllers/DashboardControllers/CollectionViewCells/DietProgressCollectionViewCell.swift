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

    var tapHandler: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGesture()
    }

    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.contentView.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        guard let tapHandler = tapHandler else { return }
        tapHandler()
    }

    func updateElements(with dietProgress: UserDiet, tapHandler: (() -> Void)?) {
        currentKcalLabel.text = "\(dietProgress.plan.currentCaloriesIntake)"
        caloriesGoalLabel.text = "/ \(dietProgress.plan.caloriesGoal!) kcal"

        let progress = Float(dietProgress.plan.currentCaloriesIntake) / Float(dietProgress.plan.caloriesGoal!)
        progressBar.progress = progress
        percentageLabel.text = "\(Int(progress * 100))%"

        self.tapHandler = tapHandler
    }
}
