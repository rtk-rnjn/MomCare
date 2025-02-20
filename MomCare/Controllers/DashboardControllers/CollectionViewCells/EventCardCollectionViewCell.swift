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

    @IBOutlet var upcomingEventLabel: UILabel!

    var tapHandler: (() -> Void)?
    var addEditEKEventPresenter: ((EKEvent?) -> Void)?
    var event: EKEvent?

    func updateElements(with event: EKEvent?, tapHandler: (() -> Void)? = nil, addEditEKEventPresenter: @escaping ((EKEvent?) -> Void)) {
        if let event {
            upcomingEventLabel.text = event.title

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM"
        }

        self.tapHandler = tapHandler
        self.addEditEKEventPresenter = addEditEKEventPresenter
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
                        self.addEditEKEventPresenter?(self.event)
                    }
                }
            }

        case .authorized:
            addEditEKEventPresenter?(event)
        default:
            break
        }
    }

    func createOrGetEvent() -> EKCalendar? {
        return createOrGetCalendar(identifierKey: "TriTrackEvent", eventType: .event, title: "MomCare - TriTrack Calendar", defaultCalendar: TriTrackViewController.eventStore.defaultCalendarForNewEvents)
    }

    func createOrGetCalendar(identifierKey: String, eventType: EKEntityType, title: String, defaultCalendar: EKCalendar?) -> EKCalendar? {
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
