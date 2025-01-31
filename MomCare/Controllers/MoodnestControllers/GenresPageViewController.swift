//
//  GenresPageViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 17/01/25.
//

import UIKit

class GenresPageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet var moodnestCollectionView: UICollectionView!
    @IBOutlet var outerView: UIView!

    override func viewDidLoad() {

        super.viewDidLoad()

        outerView.layer.cornerRadius = 30
        moodnestCollectionView.showsVerticalScrollIndicator = false
        moodnestCollectionView.backgroundColor = .clear

        moodnestCollectionView.register(UINib(nibName: "MainHeading", bundle: nil), forCellWithReuseIdentifier: "MainHeading")
        moodnestCollectionView.register(UINib(nibName: "MainImage", bundle: nil), forCellWithReuseIdentifier: "MainImage")
        moodnestCollectionView.register(UINib(nibName: "MoodNestMultipleImages", bundle: nil), forCellWithReuseIdentifier: "MoodNestMultipleImages")
        moodnestCollectionView.register(SectionHeaderCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderCollectionViewCell")

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
            fatalError()
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainHeading", for: indexPath) as? MainHeadingCollectionViewCell
            guard let cell else { fatalError("'MainHeading' me dikkat hai") }

            cell.updateSection1(with: indexPath)
            cell.layer.cornerRadius = 20

            return cell

        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainImage", for: indexPath) as? MainImageCollectionViewCell
            guard let cell else { fatalError("'MainImage' me dikkat hai") }

            let playlist = FeaturedPlaylists.playlists[indexPath.row]
            cell.updateElements(with: playlist)
            cell.layer.cornerRadius = 20

            return cell

        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoodNestMultipleImages", for: indexPath) as? MoodNestMultipleImagesCollectionViewCell
            guard let cell else { fatalError("'MoodNestMultipleImages' me dikkat hai") }

            let playlist = FeaturedPlaylists.playlists[indexPath.row]
            cell.updateElements(with: playlist)
            cell.layer.cornerRadius = 20

            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderCollectionViewCell", for: indexPath) as? SectionHeaderCollectionViewCell

        guard let header else { fatalError("the sunset is beautiful, isn't it?") }
        header.headerLabel.text = "Featured Playlists"
        header.headerLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)

        return header
    }

    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let section: NSCollectionLayoutSection

            switch sectionIndex {

            case 0:
                section = self.generateMainHeadingLayout()

            case 1:
                section = self.generateMainImageLayout()

            case 2:
                section = self.generateMultipleImageLayout()

                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top
                )

                section.boundarySupplementaryItems = [header]

            default:
                fatalError()

            }
            return section
        }
        return layout
    }

    func generateMainHeadingLayout() -> NSCollectionLayoutSection {
        let mainHeadingLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
        let mainHeading = NSCollectionLayoutItem(layoutSize: mainHeadingLayoutSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [mainHeading])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16) // Add padding around the section

        return section
    }

    func generateMainImageLayout() -> NSCollectionLayoutSection {
        let mainImageLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let mainImage = NSCollectionLayoutItem(layoutSize: mainImageLayoutSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.25))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [mainImage])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16) // Add padding around the section

        return section
    }

    func generateMultipleImageLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.4))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.4))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        group.interItemSpacing = .fixed(8)

        let section = NSCollectionLayoutSection(group: group)

        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8) // Add padding around the sectio
        section.interGroupSpacing = 8 // Space between groups

        return section
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPlaylist = FeaturedPlaylists.playlists[indexPath.item]
        performSegue(withIdentifier: "songPageSegue", sender: selectedPlaylist)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SongPageViewController {
            destinationVC.playlist = sender as? Playlist
        }
    }

}
