//
//  DashboardViewController.swift
//  MomCare
//
//  Created by Batch-2 on 15/01/25.
//

import UIKit

class DashboardViewController: UIViewController, UICollectionViewDataSource {
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "Section1Cell", bundle: nil), forCellWithReuseIdentifier: "Section1Cell")
        collectionView.register(UINib(nibName: "Section2Cell", bundle: nil), forCellWithReuseIdentifier: "Section2Cell")
        collectionView.register(UINib(nibName: "Section3Cell", bundle: nil), forCellWithReuseIdentifier: "Section3Cell")
        collectionView.register(UINib(nibName: "Section4Cell", bundle: nil), forCellWithReuseIdentifier: "Section4Cell")
        collectionView.register(UINib(nibName: "Section5Cell", bundle: nil), forCellWithReuseIdentifier: "Section5Cell")
        collectionView.register(UINib(nibName: "Section6Cell", bundle: nil), forCellWithReuseIdentifier: "Section6Cell")
        
        
        
        collectionView.collectionViewLayout = createLayout()
        collectionView.dataSource = self
        collectionView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0: // Horizontal Section (Nib 1 and 2)
                let itemSize1 = NSCollectionLayoutSize(widthDimension: .absolute(193), heightDimension: .absolute(137))
                let itemSize2 = NSCollectionLayoutSize(widthDimension: .absolute(160), heightDimension: .absolute(137))
                let item1 = NSCollectionLayoutItem(layoutSize: itemSize1)
                let item2 = NSCollectionLayoutItem(layoutSize: itemSize2)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(137))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item1,item2])
                group.interItemSpacing = .fixed(15)
//                group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 15, bottom: 10, trailing: 15)
                return section
                
            case 1: // Vertical Section (Nib 3 and 4)
                let itemSize1 = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(67))
                let itemSize2 = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(179))
                let item1 = NSCollectionLayoutItem(layoutSize: itemSize1)
                let item2 = NSCollectionLayoutItem(layoutSize: itemSize2)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(179))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item1,item2])
                group.interItemSpacing = .fixed(15)
//                group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 25, trailing: 15)
    
                return section
                
            case 2: // Horizontal Section (Nib 5 and 6)
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(164), heightDimension: .absolute(154))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(137))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(20)
//                group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 25, bottom: 10, trailing: 5)
                return section
                
            default:
                return nil
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            return collectionView.dequeueReusableCell(withReuseIdentifier: indexPath.item == 0 ? "Section1Cell" : "Section2Cell", for: indexPath)
        case 1:
            return collectionView.dequeueReusableCell(withReuseIdentifier: indexPath.item == 0 ? "Section3Cell" : "Section4Cell", for: indexPath)
        case 2:
            return collectionView.dequeueReusableCell(withReuseIdentifier: indexPath.item == 0 ? "Section5Cell" : "Section6Cell", for: indexPath)
        default:
            fatalError("Unexpected section")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    


    

    
}
