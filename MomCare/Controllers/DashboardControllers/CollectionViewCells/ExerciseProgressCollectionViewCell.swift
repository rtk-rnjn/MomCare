//
//  ExerciseProgressCollectionViewCell.swift
//  MomCare
//
//  Created by Batch-2 on 15/01/25.
//

import UIKit

class ExerciseProgressCollectionViewCell: UICollectionViewCell {

    @IBOutlet var stepsLabel: UILabel!
    @IBOutlet var exerciseDurationLabel: UILabel!
    @IBOutlet var caloriesBurnedLabel: UILabel!
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

    @IBOutlet var activityView: UIView!

    var tapHandler: (() -> Void)?
    var dashboardViewController: DashboardViewController?

    func updateElements(withTapHandler tapHandler: (() -> Void)? = nil, sender: Any? = nil) {
        self.tapHandler = tapHandler
        
        if let sender = sender as? DashboardViewController {
            dashboardViewController = sender
            
            updateStepsLabel()
            updateExerciseDurationLabel()
            updateCaloriesBurnedLabel()
        }
    }
    
    private func updateStepsLabel() {
        guard let dashboardViewController else { return }
        dashboardViewController.readStepCount() { steps in
            DispatchQueue.main.async {
                self.stepsLabel.text = "\(Int(steps))"
            }
        }
    }
    
    private func updateExerciseDurationLabel() {
        guard let dashboardViewController else { return }
        dashboardViewController.readWorkout() { duration in
            DispatchQueue.main.async {
                self.exerciseDurationLabel.text = "\(round(Double(duration)))"
            }
        }
    }
    
    private func updateCaloriesBurnedLabel() {
        guard let dashboardViewController else { return }
        dashboardViewController.readCaloriesBurned() { calories in
            DispatchQueue.main.async {
                self.caloriesBurnedLabel.text = "\(Int(calories))"
            }
        }
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
