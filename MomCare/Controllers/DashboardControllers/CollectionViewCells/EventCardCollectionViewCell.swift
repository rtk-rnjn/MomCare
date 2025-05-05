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

    @IBOutlet weak var eventCardView1: UIView!
    @IBOutlet weak var eventCardView2: UIView!
    
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
    @IBOutlet var eventDateLabel: UILabel!

    var tapHandler: (() -> Void)?
    var segueHandler: (() -> Void)?
    var event: EKEvent?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        eventCardView1.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: "#924350") : UIColor(hex: "#E9D3D3")
        }
        
        eventCardView2.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: "#924350") : UIColor(hex: "#E9D3D3")
        }
    }
    
    func updateElements(with event: EKEvent?, tapHandler: (() -> Void)? = nil, segueHandler: @escaping (() -> Void)) {
        if let event {
            upcomingEventLabel.text = event.title

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM"
            eventDateLabel.isHidden = false
            eventDateLabel.text = dateFormatter.string(from: event.startDate)
        }

        self.tapHandler = tapHandler
        self.segueHandler = segueHandler
        self.event = event
    }

    @IBAction func addEventButtonTapped(_ sender: UIButton) {
        let status = EKEventStore.authorizationStatus(for: .event)

        switch status {
        case .denied, .restricted, .notDetermined:
            TriTrackViewController.eventStore.requestFullAccessToEvents { success, _ in
                TriTrackViewController.eventStore = .init()
                if success {
                    TriTrackViewController.eventStore = EKEventStore()
                    DispatchQueue.main.async {
                        _ = self.createOrGetEvent()
                        self.segueHandler?()
                    }
                }
            }

        case .authorized:
            segueHandler?()
        default:
            break
        }
    }

    // MARK: Private

    private func createOrGetEvent() -> EKCalendar? {
        return createOrGetCalendar(identifierKey: "TriTrackEvent", eventType: .event, title: "MomCare - TriTrack Calendar", defaultCalendar: TriTrackViewController.eventStore.defaultCalendarForNewEvents)
    }

    private func createOrGetCalendar(identifierKey: String, eventType: EKEntityType, title: String, defaultCalendar: EKCalendar?) -> EKCalendar? {
        let identifier: String? = Utils.get(fromKey: identifierKey)
        if let identifier {
            return TriTrackViewController.eventStore.calendar(withIdentifier: identifier)
        }

        let newCalendar = EKCalendar(for: eventType, eventStore: TriTrackViewController.eventStore)
        newCalendar.title = title
        if let localSource = TriTrackViewController.eventStore.sources.first(where: { $0.sourceType == .local }) {
            newCalendar.source = localSource
        } else {
            newCalendar.source = defaultCalendar?.source
        }

        UserDefaults.standard.set(newCalendar.calendarIdentifier, forKey: identifierKey)

        try? TriTrackViewController.eventStore.saveCalendar(newCalendar, commit: true)

        return newCalendar
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
