//
//  EventCardCollectionViewCell.swift
//  MomCare
//
//  Created by Batch-2 on 15/01/25.
//

import UIKit
import EventKit
import EventKitUI

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

    @IBOutlet var eventCardView1: UIView!
    @IBOutlet var eventCardView2: UIView!

    @IBOutlet var upcomingEventLabel: UILabel!
    @IBOutlet var eventDateLabel: UILabel!

    @IBOutlet var addEventButton: UIButton!

    var tapHandler: (() -> Void)?
    var segueHandler: (() -> Void)?
    var event: EventInfo?

    func updateElements(with event: EventInfo?, tapHandler: (() -> Void)? = nil, segueHandler: @escaping (() -> Void)) {
        if let event {
            upcomingEventLabel.text = event.title

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM"
            eventDateLabel.isHidden = false
            addEventButton.isHidden = !eventDateLabel.isHidden
            eventDateLabel.text = dateFormatter.string(from: event.startDate ?? .init())
        }

        self.tapHandler = tapHandler
        self.segueHandler = segueHandler
        self.event = event
    }

    @IBAction func addEventButtonTapped(_ sender: UIButton) {
        Task {
            let status = EKEventStore.authorizationStatus(for: .event)
            
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    self.segueHandler?()
                }
            case .denied, .notDetermined, .restricted:
                await EventKitHandler.shared.requestAccessForEvent()
            default:
                break
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
