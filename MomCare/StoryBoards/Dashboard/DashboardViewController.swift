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
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0: // Horizontal Section (Nib 1 and 2)
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(150), heightDimension: .absolute(150))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(10)
                
                let section = NSCollectionLayoutSection(group: group)
                return section
                
            case 1: // Vertical Section (Nib 3 and 4)
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(150), heightDimension: .absolute(150))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(150), heightDimension: .fractionalHeight(1.0))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(10)
                
                let section = NSCollectionLayoutSection(group: group)
                return section
                
            case 2: // Horizontal Section (Nib 5 and 6)
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(150), heightDimension: .absolute(150))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(10)
                
                let section = NSCollectionLayoutSection(group: group)
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
