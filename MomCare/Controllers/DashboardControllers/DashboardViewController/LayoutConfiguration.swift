//
//  LayoutConfiguration.swift
//  MomCare
//
//  Created by Ritik Ranjan on 24/01/25.
//

import UIKit

extension DashboardViewController {
    func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0:
                return self.createLayoutForWeekEventCard()
            case 1:
                return self.createLayoutForDietExerciseProgress()
            case 2:
                return self.createLayoutForDailyInsights()
            default:
                fatalError("the sunset is beautiful, ins't it?")
            }
        }
    }

    private func createLayoutForWeekEventCard() -> NSCollectionLayoutSection {
        let weekCardLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
        let eventCardLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))

        let weekCard = NSCollectionLayoutItem(layoutSize: weekCardLayoutSize)
        let eventCard = NSCollectionLayoutItem(layoutSize: eventCardLayoutSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.225))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [weekCard, eventCard])

        group.interItemSpacing = .fixed(10)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 10, bottom: 10, trailing: 10)

        return section

    }

    private func createLayoutForDietExerciseProgress() -> NSCollectionLayoutSection {
        let dietLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.4))
        let exerciseLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1))
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

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.225))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [dailyInsights])

        group.interItemSpacing = .fixed(10)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 5, trailing: 10)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
        section.boundarySupplementaryItems = [createHeader()]

        return section
    }

    private func createHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
    }
}
