//
//  DietProgressCollectionViewCell.swift
//  MomCare
//
//  Created by Batch-2 on 15/01/25.
//

import UIKit

class DietProgressCollectionViewCell: UICollectionViewCell {

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGesture()
    }

    // MARK: Internal

    @IBOutlet var currentKcalLabel: UILabel!
    @IBOutlet var caloriesGoalLabel: UILabel!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var percentageLabel: UILabel!

    var tapHandler: (() -> Void)?

    func updateElements(with plan: MyPlan?, tapHandler: (() -> Void)?) {
        self.tapHandler = tapHandler
        
        guard let plan else { fatalError("yeh shaam mastaani, madhosh kiye jaaye 🎶") }
        currentKcalLabel.text = "\(plan.currentCaloriesIntake)"
        caloriesGoalLabel.text = "/ \(plan.caloriesGoal!) kcal"

        let progress = Float(plan.currentCaloriesIntake) / Float(plan.caloriesGoal!)
        progressBar.progress = progress
        percentageLabel.text = "\(Int(progress * 100))%"

        self.tapHandler = tapHandler
    }

    // MARK: Private

    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        guard let tapHandler else { return }
        tapHandler()
    }

}
