//
//  Section1CollectionViewCell.swift
//  MomCare
//
//  Created by Batch-2 on 15/01/25.
//

import UIKit

class WeekCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet var currentWeekLabel: UILabel!
    @IBOutlet var currentDayLabel: UILabel!
    @IBOutlet var currentTrimesterLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
    }

    var tapHandler: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGesture()
    }

    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        guard let tapHandler else { return }
        tapHandler()
    }

    func updateElements(with userData: User?, tapHandler: (() -> Void)?) {
//        if let userData = userData {
//
//        }
        self.tapHandler = tapHandler
    }
}
