//

//  Section4CollectionViewCell.swift

//  MomCare

//

//  Created by Batch-2 on 15/01/25.

//

import UIKit

class ExerciseProgressCollectionViewCell: UICollectionViewCell {
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
        self.contentView.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        guard let tapHandler else { return }
        tapHandler()
    }

    func updateElements(with data: UserExercise?, tapHandler: (() -> Void)?) {
        if let data {

        }
        self.tapHandler = tapHandler
    }
}
