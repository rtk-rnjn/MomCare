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
        requestAccessForHealth()

        Task {
            await requestAccessForNotification()
            DispatchQueue.main.async {
                self.loadUser()
            }
        }
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

    @IBAction func unwinToDashboard(_ segue: UIStoryboardSegue) {}

    // MARK: Private

    private let cellIdentifiers = ["WelcomeHeaderCell", "WeekCard", "EventCard", "DietProgress", "ExerciseProgress", "FocusCard", "TipCard"]
    private let headerIdentifier = "SectionHeaderView"
    private let interItemSpacing: CGFloat = 15

    private func loadUser() {
        Task {
            let success = await MomCareUser.shared.fetchUser(from: .iPhone)
            if !success {
                let fetched = await MomCareUser.shared.fetchUser(from: .database)
                if !fetched {
                    fatalError("seriously fucked up bro")
                }
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
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
