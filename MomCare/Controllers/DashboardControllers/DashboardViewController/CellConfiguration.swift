//
//  CellConfiguration.swift
//  MomCare
//
//  Created by Ritik Ranjan on 24/01/25.
//

import UIKit

extension DashboardViewController {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {

        case 0:
            let cell = prepareWelcomeHeaderCell(at: indexPath)
            return cell
        case 1:
            let cell = prepareWeekEventCell(at: indexPath)
            return cell
        case 2:
            let cell = prepareDietExersiceCell(at: indexPath)
            return cell
        case 3:
            let cell = prepareFocusTipCell(at: indexPath)
            return cell
        default:
            fatalError("i love this error")
        }
    }

    private func prepareFocusTipCell(at indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FocusCard", for: indexPath) as? FocusCardCollectionViewCell
            guard let cell else { fatalError() }

            return cell

        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TipCard", for: indexPath) as? TipCardCollectionViewCell
            guard let cell else { fatalError() }

            return cell

        default:
            fatalError("i love you baby <3")
        }
    }

    private func prepareWeekEventCell(at indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekCard", for: indexPath) as? WeekCardCollectionViewCell
            guard let cell else { fatalError() }
            cell.updateElements(with: MomCareUser.shared.user, tapHandler: weekCardTapped)

            return cell

        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCard", for: indexPath) as? EventCardCollectionViewCell
            guard let cell else { fatalError() }
            cell.updateElements(with: nil, tapHandler: eventCardTapped)
            return cell

        default:
            fatalError("kiss kiss")
        }
    }

    private func prepareDietExersiceCell(at indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DietProgress", for: indexPath) as? DietProgressCollectionViewCell

            guard let cell else { fatalError() }
            cell.updateElements(with: MomCareUser.shared.diet, tapHandler: dietCardTapped)
            return cell

        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseProgress", for: indexPath) as? ExerciseProgressCollectionViewCell
            guard let cell else { fatalError() }

            cell.updateElements(with: MomCareUser.shared.exercise, tapHandler: exersiceCardTapped)
            return cell

        default:
            fatalError("the moon is beautiful, isn't it?")
        }
    }

    private func prepareWelcomeHeaderCell(at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WelcomeHeaderCell", for: indexPath) as? WelcomeHeaderCollectionViewCell

        guard let cell else { fatalError() }
        cell.updateElements(with: "Hi, Khushi")

        return cell
    }
}

// MARK: - Event Handlers (When tapped on cards)

extension DashboardViewController {
    func eventCardTapped() {
        if let tabController = self.tabBarController as? InitialTabBarController {
            tabController.selectedIndex = 2

            if let destinationVC = (tabController.viewControllers?[2] as? UINavigationController)?.topViewController as? TriTrackViewController {
                destinationVC.currentSegmentValue = 1
            }
        }
    }

    func weekCardTapped() {
        if let tabController = self.tabBarController as? InitialTabBarController {
            tabController.selectedIndex = 2

            if let destinationVC = (tabController.viewControllers?[2] as? UINavigationController)?.topViewController as? TriTrackViewController {
                destinationVC.currentSegmentValue = 0
            }
        }
    }

    func exersiceCardTapped() {
        if let tabController = self.tabBarController as? InitialTabBarController {
            tabController.selectedIndex = 1

            if let destinationVC = (tabController.viewControllers?[1] as? UINavigationController)?.topViewController as? MyPlanViewController {
                destinationVC.currentSegmentValue = 1
            }
        }
    }

    func dietCardTapped() {
        if let tabController = self.tabBarController as? InitialTabBarController {
            tabController.selectedIndex = 1

            if let destinationVC = (tabController.viewControllers?[1] as? UINavigationController)?.topViewController as? MyPlanViewController {
                destinationVC.currentSegmentValue = 0
            }
        }
    }
}
