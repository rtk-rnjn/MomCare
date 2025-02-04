//
//  LayoutConfiguration.swift
//  MomCare
//
//  Created by Ritik Ranjan on 24/01/25.
//

import UIKit

extension DashboardViewController {
    func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ -> NSCollectionLayoutSection? in

            guard let self else { return nil }

            switch sectionIndex {
            case 0:
                return createLayoutForHeading()
            case 1:
                return createLayoutForWeekEventCard()
            case 2:
                return createLayoutForDietExerciseProgress()
            case 3:
                return createLayoutForDailyInsights()
            default:
                fatalError("the sunset is beautiful, ins't it?")
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
        let weekCardLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(137))
        let eventCardLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(137))

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
}
