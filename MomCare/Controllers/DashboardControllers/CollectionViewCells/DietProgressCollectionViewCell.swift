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
    var dashboardViewController: DashboardViewController?

    func updateElements(withTapHandler tapHandler: (() -> Void)? = nil, sender: Any? = nil) {
        self.tapHandler = tapHandler

        let plan = MomCareUser.shared.user?.plan

        guard let plan else { return }
        currentKcalLabel.text = "\(plan.currentCaloriesIntake)"
        caloriesGoalLabel.text = "/ \(plan.caloriesGoal!) kcal"

        let progress = Float(plan.currentCaloriesIntake) / Float(plan.caloriesGoal!)
        progressBar.progress = progress
        percentageLabel.text = "\(Int(progress * 100))%"

        if let sender = sender as? DashboardViewController {
            dashboardViewController = sender
        }
    }

    // MARK: Private

    private func updateLabels() {
        // TODO:
    }

    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        guard let tapHandler else { return }
        tapHandler()
    }

}
