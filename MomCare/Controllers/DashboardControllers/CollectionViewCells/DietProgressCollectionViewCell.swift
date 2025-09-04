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

                }

            }

        }

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
