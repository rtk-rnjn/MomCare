//
//  GenresPageViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 17/01/25.
//

import UIKit

class GenresPageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var moodnestCollectionView: UICollectionView!
    @IBOutlet weak var outerView: UIView!
    
    // Playlists images and labels outlets
    
    override func viewDidLoad() {
        super.viewDidLoad()
        outerView.layer.cornerRadius = 30
        moodnestCollectionView.backgroundColor = .clear
        
        // MARK: - NIB FIles Registred here
        moodnestCollectionView.register(UINib(nibName: "MainHeading", bundle: nil), forCellWithReuseIdentifier: "MainHeading")
        moodnestCollectionView.register(UINib(nibName: "MainImage", bundle: nil), forCellWithReuseIdentifier: "MainImage")
        moodnestCollectionView.register(UINib(nibName: "MoodNestMultipleImages", bundle: nil), forCellWithReuseIdentifier: "MoodNestMultipleImages")
        moodnestCollectionView.register(SectionHeaderCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderCollectionViewCell")
        
        // MARK: - DataSouce and Delegate
        moodnestCollectionView.dataSource = self
        moodnestCollectionView.delegate = self
        moodnestCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 6
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainHeading", for: indexPath) as! MainHeadingCollectionViewCell
            cell.updateSection1(with: indexPath)
            cell.layer.cornerRadius = 20
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainImage", for: indexPath) as! MainImageCollectionViewCell
            cell.updateSection2(with: indexPath)
            cell.layer.cornerRadius = 20
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoodNestMultipleImages", for: indexPath) as! MoodNestMultipleImagesCollectionViewCell
            cell.updateSection3(with: indexPath)
            cell.layer.cornerRadius = 20
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderCollectionViewCell", for: indexPath) as! SectionHeaderCollectionViewCell
            header.headerLabel.text = "Featured Playlists"
            header.headerLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            return header
        } else {
            print("Error")
            return UICollectionReusableView()
        }
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let section: NSCollectionLayoutSection
            switch sectionIndex {
            case 0:
                section = self.generateSection1Layout()
            case 1:
                section = self.generateSection2Layout()
            case 2:
                section = self.generateSection3Layout()
                
                // Add header only for Section 3
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [header]
            default:
                print("Invalid section index")
                return nil
            }
            return section
        }
        return layout
    }
        
        func generateSection1Layout() -> NSCollectionLayoutSection {
            // Define the size for the item (single heading cell)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100)) // Adjust height for the label
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // Group size (only one item, so the group size matches the item size)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            // Section setup
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16) // Add padding around the section
            return section
        }
        
        func generateSection2Layout() -> NSCollectionLayoutSection {
            // Define the size for the item (single image with a label inside)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // Group size (only one item, so the group size matches the item size)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.25))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            // Section setup
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16) // Add padding around the section
            return section
        }
        
    func generateSection3Layout() -> NSCollectionLayoutSection {
        // Define the size for the item (individual image)
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.4)) // Maintain aspect ratio

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8) // Add spacing around each item

        // Group size (two items in a group, horizontally aligned)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.4))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(8) // Ensure inter-item spacing is consistent with the top and bottom insets

        // Section setup
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8) // Add padding around the section
        section.interGroupSpacing = 8 // Space between groups
        return section
    }
    
}
    
