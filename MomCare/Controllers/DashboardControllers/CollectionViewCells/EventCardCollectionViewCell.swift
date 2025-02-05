//
//  EventCardCollectionViewCell.swift
//  MomCare
//
//  Created by Batch-2 on 15/01/25.
//

import UIKit

class EventCardCollectionViewCell: UICollectionViewCell {

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

    @IBOutlet var upcomingEventLabel: UILabel!
    @IBOutlet var upcomingEventDateLabel: UILabel!

    var tapHandler: (() -> Void)?

    func updateElements(with event: TriTrackEvent?, tapHandler: (() -> Void)?) {
        if let event {
            upcomingEventLabel.text = event.title

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM"
            upcomingEventDateLabel.text = dateFormatter.string(from: event.startDate)
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
