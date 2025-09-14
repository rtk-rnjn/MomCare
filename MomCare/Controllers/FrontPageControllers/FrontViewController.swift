//
//  FrontViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 10/01/25.
//

import UIKit
import HealthKit

class FrontViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var pageControl: UIPageControl!

    var healthStore: HKHealthStore = .init()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = createLayout()
        collectionView.backgroundColor = .none
        collectionView.alwaysBounceVertical = false

        collectionView.reloadData()
        setupAccessibility()
    }
    
    private func setupAccessibility() {
        setupBasicAccessibility(title: "Welcome to MomCare")
        
        // Configure collection view accessibility
        collectionView.accessibilityLabel = "Welcome screens"
        collectionView.accessibilityHint = "Swipe left or right to navigate through introduction slides"
        
        // Configure page control
        UIKitAccessibilityHelper.configurePageControl(pageControl, description: "Introduction page indicator")
        
        // Set up collection view for accessibility
        collectionView.isAccessibilityElement = false
        collectionView.shouldGroupAccessibilityChildren = true
        
        // Announce screen for VoiceOver users
        announceAccessibilityUpdate("Welcome to MomCare. Swipe through to learn about our features.")
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = FrontPageData.images.count

        pageControl.numberOfPages = count
        pageControl.isHidden = !(count > 1)
        return count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            return section
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FrontPageSliderCollectionViewCell", for: indexPath) as? FrontPageSliderCollectionViewCell

        guard let cell else { fatalError("aise na mujhe tum dekho, seene se laga lunga") }

        cell.imageView.image = FrontPageData.getImage(at: indexPath)
        cell.heading.text = FrontPageData.getHeading(at: indexPath)
        
        let heading = FrontPageData.getHeading(at: indexPath) ?? "Introduction slide"
        let slideNumber = indexPath.row + 1
        let totalSlides = FrontPageData.images.count
        
        UIKitAccessibilityHelper.configureCollectionViewCellWithPositionInfo(
            cell,
            title: heading,
            description: nil,
            position: "Slide \(slideNumber) of \(totalSlides)"
        )

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if pageControl.currentPage == indexPath.row {
            guard let visible = collectionView.visibleCells.first else { return }
            guard let index = collectionView.indexPath(for: visible)?.row else { return }
            pageControl.currentPage = index
            
            // Announce page change to VoiceOver users
            if UIAccessibility.isVoiceOverRunning {
                let pageNumber = index + 1
                let totalPages = FrontPageData.images.count
                announceAccessibilityUpdate("Page \(pageNumber) of \(totalPages)")
            }
        }
    }
}
