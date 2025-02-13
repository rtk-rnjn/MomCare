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

class DashboardViewController: UIViewController, UICollectionViewDataSource {

    // MARK: Internal

    @IBOutlet var collectionView: UICollectionView!
    var healthStore: HKHealthStore?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        collectionView.showsVerticalScrollIndicator = false

        requestForNotification()
        requestForHealthKit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        collectionView.reloadData()
    }

    func addHKActivityRing(to cellView: UIView, with summary: HKActivitySummary?) {
        let summary = HKActivitySummary()
        summary.activeEnergyBurned = HKQuantity(unit: .kilocalorie(), doubleValue: 300)
        summary.activeEnergyBurnedGoal = HKQuantity(unit: .kilocalorie(), doubleValue: 500)
        summary.appleExerciseTime = HKQuantity(unit: .minute(), doubleValue: 30)
        summary.appleExerciseTimeGoal = HKQuantity(unit: .minute(), doubleValue: 60)
        summary.appleStandHours = HKQuantity(unit: .count(), doubleValue: 10)
        summary.appleStandHoursGoal = HKQuantity(unit: .count(), doubleValue: 12)

        
        let HKview = HKActivityRingView()
        HKview.setActivitySummary(summary, animated: true)
        HKview.translatesAutoresizingMaskIntoConstraints = false
        cellView.addSubview(HKview)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : 2
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderView", for: indexPath) as? DashboardSectionHeaderCollectionViewCell

        guard let headerView else { fatalError() }

        headerView.titleLabel.text = (indexPath.section == 2) ? "Progress" : "Daily Insights"

        return headerView
    }

    // MARK: Private

    private let cellIdentifiers = ["WelcomeHeaderCell", "WeekCard", "EventCard", "DietProgress", "ExerciseProgress", "FocusCard", "TipCard"]
    private let headerIdentifier = "SectionHeaderView"
    private let interItemSpacing: CGFloat = 15

    private func requestForNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            } else if granted {
                center.getNotificationSettings { settings in
                    guard settings.authorizationStatus == .authorized else { return }
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            } else {
                print("❌ Notification permission denied")
            }
        }
    }

    private func requestForHealthKit() {
        healthStore = HKHealthStore()

        guard let healthStore else { return }

        let allTypes = Set([
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKObjectType.quantityType(forIdentifier: .appleStandTime)!,
            HKObjectType.activitySummaryType()
        ])

        healthStore.requestAuthorization(toShare: nil, read: allTypes) { success, _ in
            if success {
                print("HealthKit permission granted")
            }
        }
    }

    private func setupCollectionView() {
        registerCells()

        collectionView.collectionViewLayout = createLayout()
        collectionView.dataSource = self
    }

    private func registerCells() {
        for cell in cellIdentifiers {
            collectionView.register(UINib(nibName: cell, bundle: nil), forCellWithReuseIdentifier: cell)
        }

        collectionView.register(UINib(nibName: headerIdentifier, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }

}
