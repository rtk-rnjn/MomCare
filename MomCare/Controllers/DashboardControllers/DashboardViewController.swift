//
//  DashboardViewController.swift
//  MomCare
//
//  Created by Batch-2 on 15/01/25.
//

import UIKit

class DashboardViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet var collectionView: UICollectionView!
    private let cellIdentifiers = ["WelcomeHeaderCell", "WeekCard", "EventCard", "DietProgress", "ExerciseProgress", "FocusCard", "TipCard"]
    private let headerIdentifier = "SectionHeaderView"
    private let interItemSpacing: CGFloat = 15

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        collectionView.showsVerticalScrollIndicator = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        collectionView.reloadData()
    }

    private func setupCollectionView() {
        registerCells()

        collectionView.collectionViewLayout = createLayout()
        collectionView.dataSource = self
    }

    private func registerCells() {
        cellIdentifiers.forEach { cell in
            collectionView.register(UINib(nibName: cell, bundle: nil), forCellWithReuseIdentifier: cell)
        }

        collectionView.register(UINib(nibName: headerIdentifier, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {

        UICollectionViewCompositionalLayout { [weak self] (sectionIndex, _) -> NSCollectionLayoutSection? in

            guard let self = self else { return nil }

            switch sectionIndex {
            case 0:
                return self.createLayoutForHeading()
            case 1:
                return self.createLayoutForWeekEventCard()
            case 2:
                return self.createLayoutForDietExerciseProgress()
            case 3:
                return self.createLayoutForDailyInsights()
            default:
                fatalError()
            }
        }
    }

    private func createLayoutForHeading() -> NSCollectionLayoutSection {
        let userHeadingLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
        let userHeading = NSCollectionLayoutItem(layoutSize: userHeadingLayoutSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [userHeading])
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 5, trailing: 15)
        
        return section
    }

    private func createLayoutForWeekEventCard() -> NSCollectionLayoutSection {
        let weekCardLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.55), heightDimension: .absolute(137))
        let eventCardLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .absolute(137))
        
        let weekCard = NSCollectionLayoutItem(layoutSize: weekCardLayoutSize)
        let eventCard = NSCollectionLayoutItem(layoutSize: eventCardLayoutSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(137))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [weekCard, eventCard])

        group.interItemSpacing = .fixed(10)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)

        return section

    }

    private func createLayoutForDietExerciseProgress() -> NSCollectionLayoutSection {
        let dietLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(67))
        let exerciseLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(179))
        let dietProgress = NSCollectionLayoutItem(layoutSize: dietLayoutSize)
        let exerciseProgress = NSCollectionLayoutItem(layoutSize: exerciseLayoutSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(179))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [dietProgress, exerciseProgress])

        group.interItemSpacing = .fixed(15)
        group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 15, trailing: 10)
        section.boundarySupplementaryItems = [createHeader()]

        return section

    }

    private func createLayoutForDailyInsights() -> NSCollectionLayoutSection {
        let dailyInsightsLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(154))
        let dailyInsights = NSCollectionLayoutItem(layoutSize: dailyInsightsLayoutSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(137))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [dailyInsights])
        group.interItemSpacing = .fixed(20)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 10, trailing: 5)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 45, trailing: 15)
        section.boundarySupplementaryItems = [createHeader()]
        return section
    }

    private func createHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        default: return 2
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {

        case 0:
            let cell = prepareWelcomeHeaderCell(at: indexPath)
            return cell
        case 1:
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekCard", for: indexPath) as? WeekCardCollectionViewCell
                guard let cell = cell else { fatalError() }
                return cell
            }
            return collectionView.dequeueReusableCell(withReuseIdentifier: indexPath.item == 0 ? "WeekCard" : "EventCard", for: indexPath)
        case 2:
            let cell = prepareDietExersiceCell(at: indexPath)
            return cell
        case 3:
            return collectionView.dequeueReusableCell(withReuseIdentifier: indexPath.item == 0 ? "FocusCard" : "TipCard", for: indexPath)
        default:
            fatalError("Unexpected section")
        }
    }
    
    private func prepareDietExersiceCell(at indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DietProgress", for: indexPath) as? DietProgressCollectionViewCell
            
            guard let cell = cell else { fatalError() }
            cell.updateElements(with: MomCareUser.shared.diet)
            return cell
        }

        if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseProgress", for: indexPath) as? ExerciseProgressCollectionViewCell
            guard let cell = cell else { fatalError() }
            return cell
        }
        
        fatalError()
    }
    
    private func prepareWelcomeHeaderCell(at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WelcomeHeaderCell", for: indexPath) as? WelcomeHeaderCollectionViewCell
        
        guard let cell = cell else { fatalError() }
        cell.updateElements(with: "Hi, Khushi")
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Unexpected element kind")
        }

        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderView", for: indexPath) as? DashboardSectionHeaderCollectionViewCell
        
        guard let headerView = headerView else { fatalError("") }

        headerView.titleLabel.text = (indexPath.section == 2) ? "Progress" : "Daily Insights"

        return headerView
    }
}
