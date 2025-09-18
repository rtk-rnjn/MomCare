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

        updateStepsLabel()
        updateExerciseDurationLabel()
        updateCaloriesBurnedLabel()
        
        // Apply Dynamic Type to all labels
        stepsLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        stepsLabel.adjustsFontForContentSizeCategory = true
        
        exerciseDurationLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        exerciseDurationLabel.adjustsFontForContentSizeCategory = true
        
        caloriesBurnedLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        caloriesBurnedLabel.adjustsFontForContentSizeCategory = true
    }

    // MARK: Private

    private func updateStepsLabel() {
        Task {
            await HealthKitHandler.shared.readStepCount { steps in
                DispatchQueue.main.async {
                    self.stepsLabel.text = "\(Int(steps))"
                    self.stepsLabel.accessibilityLabel = "\(Int(steps)) steps today"
                }
            }
        }
    }

    private func updateExerciseDurationLabel() {
        Task {
            await HealthKitHandler.shared.readWorkout { duration in
                DispatchQueue.main.async {
                    let roundedDuration = round(Double(duration))
                    self.exerciseDurationLabel.text = "\(roundedDuration)"
                    self.exerciseDurationLabel.accessibilityLabel = "\(roundedDuration) minutes of exercise today"
                }
            }
        }
    }

    private func updateCaloriesBurnedLabel() {
        Task {
            await HealthKitHandler.shared.readCaloriesBurned { calories in
                DispatchQueue.main.async {
                    self.caloriesBurnedLabel.text = "\(Int(calories))"
                    self.caloriesBurnedLabel.accessibilityLabel = "\(Int(calories)) calories burned today"
                    
                    // Configure cell accessibility after all data is loaded
                    let stepsText = self.stepsLabel.text ?? "0"
                    let durationText = self.exerciseDurationLabel.text ?? "0"
                    let caloriesText = self.caloriesBurnedLabel.text ?? "0"
                    
                    self.isAccessibilityElement = true
                    self.accessibilityLabel = "Exercise progress: \(stepsText) steps, \(durationText) minutes exercise, \(caloriesText) calories burned today"
                    self.accessibilityHint = "Double tap to view detailed exercise information"
                    self.accessibilityTraits = .button
                }
            }
        }
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
