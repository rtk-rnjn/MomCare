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

    override func awakeFromNib() {
        super.awakeFromNib()

        dietCardView.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: "#924350") : UIColor(hex: "#E9D3D3")
        }
    }

    func updateElements(withTapHandler tapHandler: (() -> Void)? = nil) {
        self.tapHandler = tapHandler

        guard let dueDate = MomCareUser.shared.user?.medicalData?.dueDate else { return }

        let pregnancyData = Utils.pregnancyWeekAndDay(dueDate: dueDate)
        let caloriesGoal = Utils.getCaloriesGoal(trimester: pregnancyData?.trimester ?? "")
        caloriesGoalLabel.text = "/ \(Int(caloriesGoal)) kcal"

        let progress = Float(currentCaloriesIntake) / Float(caloriesGoal)
        progressBar.progress = progress

        var displayProgress = Int(progress * 100)
        displayProgress = displayProgress > 100 ? 100 : displayProgress
        percentageLabel.text = "\(displayProgress)%"

        updateLabels()
    }

    // MARK: Private

    private func updateLabels() {
        HealthKitHandler.shared.readCaloriesIntake { caloriesIntake in
            DispatchQueue.main.async {
                self.currentKcalLabel.text = "\(Int(caloriesIntake))"
                self.currentCaloriesIntake = Int(caloriesIntake)
            }
        }
    }

    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        tapHandler?()
    }

}
