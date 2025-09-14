//
//  ExerciseProgressCollectionViewCell.swift
//  MomCare
//
//  Created by Batch-2 on 15/01/25.
//

import UIKit

class ExerciseProgressCollectionViewCell: UICollectionViewCell {

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

    @IBOutlet var stepsLabel: UILabel!
    @IBOutlet var exerciseDurationLabel: UILabel!
    @IBOutlet var caloriesBurnedLabel: UILabel!
    @IBOutlet var activityView: UIView!

    var tapHandler: (() -> Void)?

    func updateElements(withTapHandler tapHandler: (() -> Void)? = nil) {
        self.tapHandler = tapHandler
        
        // Set up accessibility
        setupAccessibility()

        updateStepsLabel()
        updateExerciseDurationLabel()
        updateCaloriesBurnedLabel()
    }
    
    private func setupAccessibility() {
        // Enable Dynamic Type support
        stepsLabel.adjustsFontForContentSizeCategory = true
        exerciseDurationLabel.adjustsFontForContentSizeCategory = true
        caloriesBurnedLabel.adjustsFontForContentSizeCategory = true
        
        // Set up accessibility traits
        contentView.accessibilityTraits = .button
        contentView.accessibilityLabel = "Exercise progress"
        contentView.accessibilityHint = "Tap to view detailed exercise information"
        
        // Hide individual labels from accessibility since we'll combine them
        stepsLabel.isAccessibilityElement = false
        exerciseDurationLabel.isAccessibilityElement = false
        caloriesBurnedLabel.isAccessibilityElement = false
    }

    // MARK: Private

    private func updateStepsLabel() {
        Task {
            await HealthKitHandler.shared.readStepCount { steps in
                DispatchQueue.main.async {
                    self.stepsLabel.text = "\(Int(steps))"
                    self.updateAccessibilityValue()
                }
            }
        }
    }

    private func updateExerciseDurationLabel() {
        Task {
            await HealthKitHandler.shared.readWorkout { duration in
                DispatchQueue.main.async {
                    self.exerciseDurationLabel.text = "\(round(Double(duration)))"
                    self.updateAccessibilityValue()
                }
            }
        }
    }

    private func updateCaloriesBurnedLabel() {
        Task {
            await HealthKitHandler.shared.readCaloriesBurned { calories in
                DispatchQueue.main.async {
                    self.caloriesBurnedLabel.text = "\(Int(calories))"
                    self.updateAccessibilityValue()
                }
            }
        }
    }
    
    private func updateAccessibilityValue() {
        let steps = stepsLabel.text ?? "0"
        let duration = exerciseDurationLabel.text ?? "0"
        let calories = caloriesBurnedLabel.text ?? "0"
        
        contentView.accessibilityValue = "Steps: \(steps), Exercise duration: \(duration) minutes, Calories burned: \(calories)"
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
