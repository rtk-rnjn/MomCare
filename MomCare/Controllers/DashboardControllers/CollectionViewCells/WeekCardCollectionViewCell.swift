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

    @IBOutlet var currentWeekLabel: UILabel!
    @IBOutlet var currentDayLabel: UILabel!
    @IBOutlet var currentTrimesterLabel: UILabel!

    var tapHandler: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
    }

    func updateElements(with userData: User?, tapHandler: (() -> Void)?) {
//        if let userData = userData {
//
//        }
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
