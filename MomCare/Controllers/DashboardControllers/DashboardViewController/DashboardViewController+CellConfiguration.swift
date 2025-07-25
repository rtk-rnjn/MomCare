//
//  DashboardViewController+CellConfiguration.swift
//  MomCare
//
//  Created by Ritik Ranjan on 24/01/25.
//

import UIKit

extension DashboardViewController {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {

        case 0:
            return prepareWeekEventCell(at: indexPath)

        case 1:
            return prepareDietExersiceCell(at: indexPath)

        case 2:
            return prepareFocusTipCell(at: indexPath)

        default:
            fatalError("i love this error")
        }
    }

    private func prepareFocusTipCell(at indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FocusCard", for: indexPath) as? FocusCardCollectionViewCell
            guard let cell else { fatalError("'FocusCard' not found") }
            cell.startShimmer()
            if !dataFetched {
                return cell
            }
            cell.stopShimmer()

            if let tip {
                cell.updateElements(with: tip)
            }

            return cell

        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TipCard", for: indexPath) as? TipCardCollectionViewCell
            guard let cell else { fatalError("'TipCard' not found") }
            cell.startShimmer()
            if !dataFetched {
                return cell
            }
            cell.stopShimmer()
            if let tip {
                cell.updateElements(with: tip)
            }

            return cell

        default:
            fatalError("i love you baby <3")
        }
    }

    private func prepareWeekEventCell(at indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekCard", for: indexPath) as? WeekCardCollectionViewCell
            guard let cell else { fatalError("'WeekCard' not found") }
            cell.startShimmer()
            if !dataFetched {
                return cell
            }
            cell.stopShimmer()
            cell.updateElements(with: MomCareUser.shared.user, tapHandler: weekCardTapped)

            return cell

        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCard", for: indexPath) as? EventCardCollectionViewCell
            guard let cell else { fatalError("'EventCard' not found") }
            cell.startShimmer()
            if !dataFetched {
                return cell
            }
            cell.stopShimmer()
            Task {
                let event = await EventKitHandler.shared.fetchUpcomingAppointment()
                DispatchQueue.main.async {
                    cell.updateElements(with: event, tapHandler: self.eventCardTapped) {
                        self.performSegue(withIdentifier: "segueShowAddEventTableViewController", sender: nil)
                    }
                }
            }
            return cell

        default:
            fatalError("pyar kiya to darna kya")
        }
    }

    private func prepareDietExersiceCell(at indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DietProgress", for: indexPath) as? DietProgressCollectionViewCell

            guard let cell else { fatalError("'DietProgress' not found") }
            cell.startShimmer()
            if !dataFetched {
                return cell
            }
            cell.stopShimmer()
            cell.updateElements(withTapHandler: dietCardTapped)
            return cell

        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseProgress", for: indexPath) as? ExerciseProgressCollectionViewCell
            guard let cell else { fatalError("'ExerciseProgress' not found") }
            cell.startShimmer()
            if !dataFetched {
                return cell
            }
            cell.stopShimmer()

            cell.updateElements(withTapHandler: exersiceCardTapped)
            addHKActivityRing(to: cell.activityView, withSummary: nil)
            return cell

        default:
            fatalError("the moon is beautiful, isn't it?")
        }
    }

}

// MARK: - Event Handlers (When tapped on cards)

extension DashboardViewController {
    func eventCardTapped() {
        if let tabController = tabBarController as? InitialTabBarController {
            tabController.selectedIndex = 2
            if let destinationVC = (tabController.viewControllers?[2] as? UINavigationController)?.topViewController as? TriTrackViewController {
                destinationVC.currentSegmentValue = 1
            }
        }
    }

    func weekCardTapped() {
        if let tabController = tabBarController as? InitialTabBarController {
            tabController.selectedIndex = 2

            if let destinationVC = (tabController.viewControllers?[2] as? UINavigationController)?.topViewController as? TriTrackViewController {
                destinationVC.currentSegmentValue = 0
            }
        }
    }

    func exersiceCardTapped() {
        if let tabController = tabBarController as? InitialTabBarController {
            tabController.selectedIndex = 1

            if let destinationVC = (tabController.viewControllers?[1] as? UINavigationController)?.topViewController as? MyPlanViewController {
                destinationVC.currentSegmentValue = 1
            }
        }
    }

    func dietCardTapped() {
        if let tabController = tabBarController as? InitialTabBarController {
            tabController.selectedIndex = 1

            if let destinationVC = (tabController.viewControllers?[1] as? UINavigationController)?.topViewController as? MyPlanViewController {
                destinationVC.currentSegmentValue = 0
            }
        }
    }
}
