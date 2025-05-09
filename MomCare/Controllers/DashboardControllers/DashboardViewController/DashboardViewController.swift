//
//  DashboardViewController.swift
//  MomCare
//
//  Created by Batch-2 on 15/01/25.
//

import UIKit
import UserNotifications
import HealthKit
import HealthKitUI
import EventKit

class DashboardViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {

    // MARK: Internal

    static let healthStore: HKHealthStore = .init()

    @IBOutlet var collectionView: UICollectionView!
    var addEventTableViewController: AddEventTableViewController?
    var profileButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCollectionView()
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl = refreshControl
        requestAccessForHealth()

        collectionView.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = true
        setupProfileButton()

        Task {
            await requestAccessForNotification()

            await self.loadUser()

            if var user = MomCareUser.shared.user, let medical = user.medicalData {
                let meals = await MyPlanMLModel.fetchPlans(from: medical)
                user.plan = meals

                MomCareUser.shared.setUser(user)
            }

            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }

        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        collectionView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowAddEventTableViewController" {
            if let navigationController = segue.destination as? UINavigationController {
                let addEventTableViewController = navigationController.viewControllers.first as? AddEventTableViewController
                self.addEventTableViewController = addEventTableViewController

                addEventTableViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAddEvent))
                addEventTableViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAddEvent))
            }
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderView", for: indexPath) as? DashboardSectionHeaderCollectionViewCell

        guard let headerView else { fatalError() }

        headerView.titleLabel.text = (indexPath.section == 2) ? "Progress" : "Daily Insights"

        return headerView
    }

    @IBAction func unwinToDashboard(_ segue: UIStoryboardSegue) {}

    func setupProfileButton() {
        if let navigationBar = navigationController?.navigationBar {
            let customView = UIView()
            customView.backgroundColor = .clear

            let profileBtn = UIButton()
            if let profileImage = UIImage(named: "person.crop.circle.fill") {
                profileBtn.setImage(profileImage, for: .normal)
            }

            profileBtn.addTarget(self, action: #selector(profileIconTapped), for: .touchUpInside)

            profileBtn.tintColor = .gray

            customView.addSubview(profileBtn)
            navigationBar.addSubview(customView)

            profileBtn.translatesAutoresizingMaskIntoConstraints = false
            customView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                // Place custom view at the bottom right
                customView.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor, constant: -16),
                customView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -10),
                customView.widthAnchor.constraint(equalToConstant: 40),
                customView.heightAnchor.constraint(equalToConstant: 40),

                profileBtn.centerXAnchor.constraint(equalTo: customView.centerXAnchor),
                profileBtn.centerYAnchor.constraint(equalTo: customView.centerYAnchor),
                profileBtn.widthAnchor.constraint(equalToConstant: 36),
                profileBtn.heightAnchor.constraint(equalToConstant: 36)
            ])

            profileButton = profileBtn
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if offsetY > 0 {
            hideProfileButton()
        } else {
            showProfileButton()
        }
    }

    @objc func profileIconTapped() {
        performSegue(withIdentifier: "segueShowProfilePageTableViewController", sender: nil)
    }

    // MARK: Private

    private let refreshControl: UIRefreshControl = .init()

    private let cellIdentifiers = ["WeekCard", "EventCard", "DietProgress", "ExerciseProgress", "FocusCard", "TipCard"]
    private let headerIdentifier = "SectionHeaderView"
    private let interItemSpacing: CGFloat = 15

    @objc private func didPullToRefresh(_ sender: Any) {
        refreshControl.beginRefreshing()
        Task {
            await loadUser()

            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }

    private func loadUser() async {
        let success = await MomCareUser.shared.fetchUser(from: .iPhone)
        if !success {
            let fetched = await MomCareUser.shared.fetchUser(from: .database)
            if !fetched {
                fatalError("seriously fucked up bro")
            }
        }
    }

    private func prepareCollectionView() {
        registerCells()

        collectionView.collectionViewLayout = createLayout()
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    private func registerCells() {
        for cell in cellIdentifiers {
            collectionView.register(UINib(nibName: cell, bundle: nil), forCellWithReuseIdentifier: cell)
        }

        collectionView.register(UINib(nibName: headerIdentifier, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }

    @objc private func cancelAddEvent() {
        dismiss(animated: true)
    }

    @objc private func doneAddEvent() {
        guard let eventTVC = addEventTableViewController,
              let title = eventTVC.titleField.text else { return }
        let event = EKEvent(eventStore: TriTrackViewController.eventStore)
        event.title = title
        event.location = ((eventTVC.locationField.text?.isEmpty) != nil) ? eventTVC.locationField.text : nil
        event.startDate = eventTVC.startDateTimePicker.date
        event.isAllDay = eventTVC.allDaySwitch.isOn

        if let repeatAfter = eventTVC.selectedRepeatOption {
            event.recurrenceRules = TriTrackViewController.createRecurrenceRule(for: repeatAfter)
        }
        if let alertTime = eventTVC.selectedAlertTimeOption {
            event.addAlarm(EKAlarm(relativeOffset: -alertTime))
        }
        event.endDate = eventTVC.allDaySwitch.isOn ? event.startDate : eventTVC.endDateTimePicker.date.addingTimeInterval(eventTVC.selectedTravelTimeOption ?? 0)
        event.calendar = createOrGetEvent()

        try? TriTrackViewController.eventStore.save(event, span: .thisEvent, commit: true)
        dismiss(animated: true) {
            self.collectionView.reloadSections([1])
        }
    }

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

    private func hideProfileButton() {
        if let profileBtn = profileButton {
            profileBtn.alpha = 0
        }
    }

    private func showProfileButton() {
        if let profileBtn = profileButton {
            UIView.animate(withDuration: 0.5) {
                profileBtn.alpha = 1
            }
        }
    }

}
