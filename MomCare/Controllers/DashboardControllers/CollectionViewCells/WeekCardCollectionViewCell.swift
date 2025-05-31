//
//  WeekCardCollectionViewCell.swift
//  MomCare
//
//  Created by Batch-2 on 15/01/25.
//

import UIKit

class WeekCardCollectionViewCell: UICollectionViewCell {

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

    @IBOutlet var weekCardView1: UIView!
    @IBOutlet var weekCardView2: UIView!

    @IBOutlet var currentWeekLabel: UILabel!
    @IBOutlet var currentDayLabel: UILabel!
    @IBOutlet var currentTrimesterLabel: UILabel!

    var tapHandler: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        DispatchQueue.main.async {
            self.contentView.layer.cornerRadius = 16
            self.contentView.layer.masksToBounds = true
        }
    }

    func updateElements(with userData: User?, tapHandler: (() -> Void)?) {
        if let userData {
            if let dueDate = userData.medicalData?.dueDate {
                let weekAndDay = Utils.pregnancyWeekAndDay(dueDate: dueDate)
                currentWeekLabel.text = "Week \(String(weekAndDay?.week ?? 0))"
                currentDayLabel.text = "Day \(String(weekAndDay?.day ?? 0))"
                currentTrimesterLabel.text = "Trimester \(String(weekAndDay?.trimester ?? "0"))"
            } else {
                currentWeekLabel.text = "Week NaN"
                currentDayLabel.text = "Day NaN"
                currentTrimesterLabel.text = "Trimester NaN"
            }
        }
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
