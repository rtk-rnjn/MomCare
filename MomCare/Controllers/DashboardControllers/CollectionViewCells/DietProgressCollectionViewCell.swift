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

    @IBOutlet var dietCardView: UIView!

    @IBOutlet var currentKcalLabel: UILabel!
    @IBOutlet var caloriesGoalLabel: UILabel!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var percentageLabel: UILabel!

    var tapHandler: (() -> Void)?

    var currentCaloriesIntake: Int = 0

    func updateElements(withTapHandler tapHandler: (() -> Void)? = nil) {
        self.tapHandler = tapHandler

        let caloriesGoal = MomCareUser.shared.user?.plan.totalCalories ?? 1
        caloriesGoalLabel.text = "/ \(Int(caloriesGoal)) kcal"
        
        // Set up accessibility
        setupAccessibility()

        Task {
            await HealthKitHandler.shared.readCaloriesIntake { caloriesIntake in
                DispatchQueue.main.async {
                    self.currentKcalLabel.text = "\(Int(caloriesIntake))"
                    self.currentCaloriesIntake = Int(caloriesIntake)
                    var progress = Float(self.currentCaloriesIntake) / Float(caloriesGoal)
                    progress = max(0, min(progress, 1))

                    self.progressBar.progress = progress

                    var displayProgress = Int(progress * 100)
                    displayProgress = displayProgress > 100 ? 100 : displayProgress
                    self.percentageLabel.text = "\(displayProgress)%"
                    
                    // Update accessibility after data loads
                    self.updateAccessibilityWithCurrentData()
                }
            }
        }
    }
    
    private func setupAccessibility() {
        // Enable Dynamic Type support
        currentKcalLabel.adjustsFontForContentSizeCategory = true
        caloriesGoalLabel.adjustsFontForContentSizeCategory = true
        percentageLabel.adjustsFontForContentSizeCategory = true
        
        // Set up accessibility traits
        contentView.accessibilityTraits = .button
        contentView.accessibilityLabel = "Diet progress"
        contentView.accessibilityHint = "Tap to view detailed diet information"
        
        // Hide individual labels from accessibility since we'll combine them
        currentKcalLabel.isAccessibilityElement = false
        caloriesGoalLabel.isAccessibilityElement = false
        percentageLabel.isAccessibilityElement = false
        progressBar.isAccessibilityElement = false
    }
    
    private func updateAccessibilityWithCurrentData() {
        let caloriesGoal = MomCareUser.shared.user?.plan.totalCalories ?? 1
        let progress = Float(currentCaloriesIntake) / Float(caloriesGoal)
        let displayProgress = Int(min(progress * 100, 100))
        
        contentView.accessibilityValue = "Current intake: \(currentCaloriesIntake) calories out of \(Int(caloriesGoal)) goal. \(displayProgress)% complete"
    }

    // MARK: Private

    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        tapHandler?()
    }

}
