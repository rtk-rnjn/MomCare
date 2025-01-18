//
//  DashboardViewController.swift
//  MomCare
//
//  Created by Batch-2 on 15/01/25.
//

import UIKit

class DashboardViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    private let cellIdentifiers = ["WelcomeHeaderCell", "Section1Cell", "Section2Cell", "Section3Cell", "Section4Cell", "Section5Cell", "Section6Cell"]
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
            case 0: // WelcomeHeaderCell
                return self.createSingleItemSection()
            case 1: // Section1Cell, Section2Cell (Horizontal)
                return self.createTwoItemHorizontalSection()
            case 2: // Section3Cell, Section4Cell (Vertical with header)
                return self.createVerticalSectionWithHeader()
            case 3: // Section5Cell, Section6Cell (Horizontal with header, equal sizes)
                return self.createEqualSizeHorizontalSectionWithHeader()
            default:
                return nil
            }
        }
    }
    
    private func createSingleItemSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 5, trailing: 15)
        return section
        
    }
    
    private func createTwoItemHorizontalSection() -> NSCollectionLayoutSection {
        let itemSize1 = NSCollectionLayoutSize(widthDimension: .absolute(193), heightDimension: .absolute(137))
        let itemSize2 = NSCollectionLayoutSize(widthDimension: .absolute(160), heightDimension: .absolute(137))
        let item1 = NSCollectionLayoutItem(layoutSize: itemSize1)
        let item2 = NSCollectionLayoutItem(layoutSize: itemSize2)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(137))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item1, item2])
        group.interItemSpacing = .fixed(10)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 5)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
        return section
    }
    
    private func createVerticalSectionWithHeader() -> NSCollectionLayoutSection {
        let itemSize1 = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(67))
        let itemSize2 = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(179))
        let item1 = NSCollectionLayoutItem(layoutSize: itemSize1)
        let item2 = NSCollectionLayoutItem(layoutSize: itemSize2)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(179))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item1, item2])
        group.interItemSpacing = .fixed(15)
        group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 15, trailing: 10)
        section.boundarySupplementaryItems = [createHeader()]
        return section
    }
    
    private func createEqualSizeHorizontalSectionWithHeader() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(164), heightDimension: .absolute(154))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(137))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(30)
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

    // MARK: - UICollectionViewDataSource

extension DashboardViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return 1 // Welcome
        case 1: return 2 // Section1, Section2
        case 2: return 2 // Section3, Section4
        case 3: return 2 // Section5, Section6
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "WelcomeHeaderCell", for: indexPath)
        case 1:
            return collectionView.dequeueReusableCell(withReuseIdentifier: indexPath.item == 0 ? "Section1Cell" : "Section2Cell", for: indexPath)
        case 2:
            return collectionView.dequeueReusableCell(withReuseIdentifier: indexPath.item == 0 ? "Section3Cell" : "Section4Cell", for: indexPath)
        case 3:
            return collectionView.dequeueReusableCell(withReuseIdentifier: indexPath.item == 0 ? "Section5Cell" : "Section6Cell", for: indexPath)
        default:
            fatalError("Unexpected section")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Unexpected element kind")
        }
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderView", for: indexPath) as! SectionHeaderViewCollectionViewCell
        headerView.titleLabel.text = (indexPath.section==2) ? "Progress" : "Daily Insights"
        return headerView
    }
}
