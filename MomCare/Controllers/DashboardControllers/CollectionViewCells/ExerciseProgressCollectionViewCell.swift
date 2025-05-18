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
    }

    // MARK: Private

    private func updateStepsLabel() {
        HealthKitHandler.shared.readStepCount { steps in
            DispatchQueue.main.async {
                self.stepsLabel.text = "\(Int(steps))"
            }
        }
    }

    private func updateExerciseDurationLabel() {
        HealthKitHandler.shared.readWorkout { duration in
            DispatchQueue.main.async {
                self.exerciseDurationLabel.text = "\(round(Double(duration)))"
            }
        }
    }

    private func updateCaloriesBurnedLabel() {
        HealthKitHandler.shared.readCaloriesBurned { calories in
            DispatchQueue.main.async {
                self.caloriesBurnedLabel.text = "\(Int(calories))"
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
