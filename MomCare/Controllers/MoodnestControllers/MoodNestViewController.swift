//
//  MoodnestViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 17/01/25.
//

import UIKit

enum MoodNestCollectionViewCellType: Int {
    case mainHeading = 0
    case mainImage = 1
    case multipleImages = 2
}

class MoodNestViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: Internal

    @IBOutlet var moodnestCollectionView: UICollectionView!
    @IBOutlet var outerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        outerView.layer.cornerRadius = 30
        registerAllNibs()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SongPageViewController {
            destinationVC.playlist = sender as? Playlist
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let cellType = MoodNestCollectionViewCellType(rawValue: section)
        guard let cellType else { fatalError("cellType is nil") }

        switch cellType {
        case .mainHeading, .mainImage:
            return 1

        case .multipleImages:
            return 6
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellType = MoodNestCollectionViewCellType(rawValue: indexPath.section)
        guard let cellType else { fatalError("cellType is nil") }
        switch cellType {
        case .mainHeading:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainHeading", for: indexPath) as? MainHeadingCollectionViewCell
            guard let cell else { fatalError("'MainHeading' me dikkat hai") }

            cell.updateMainHeading(with: indexPath)
            cell.layer.cornerRadius = 20

            return cell

        case .mainImage:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainImage", for: indexPath) as? MainImageCollectionViewCell
            guard let cell else { fatalError("'MainImage' me dikkat hai") }

            let playlist = SampleFeaturedPlaylists.playlists[indexPath.row]
            cell.updateElements(with: playlist)
            cell.layer.cornerRadius = 20

            return cell

        case .multipleImages:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoodNestMultipleImages", for: indexPath) as? MoodNestMultipleImagesCollectionViewCell
            guard let cell else { fatalError("'MoodNestMultipleImages' me dikkat hai") }

            let playlist = SampleFeaturedPlaylists.playlists[indexPath.row]
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
        return UICollectionViewCompositionalLayout { (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let section: NSCollectionLayoutSection
            let cellType = MoodNestCollectionViewCellType(rawValue: sectionIndex)
            guard let cellType else { fatalError("dekha hai pehli baar, saajan ki aankhon mein pyaar") }

            switch cellType {

            case .mainHeading:
                section = self.generateMainHeadingLayout()

            case .mainImage:
                section = self.generateMainImageLayout()

            case .multipleImages:
                section = self.generateMultipleImageLayout()

                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top
                )

                section.boundarySupplementaryItems = [header]
            }
            return section
        }
    }

    func generateMainHeadingLayout() -> NSCollectionLayoutSection {
        let mainHeadingLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
        let mainHeading = NSCollectionLayoutItem(layoutSize: mainHeadingLayoutSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [mainHeading])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16)

        return section
    }

    func generateMainImageLayout() -> NSCollectionLayoutSection {
        let mainImageLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let mainImage = NSCollectionLayoutItem(layoutSize: mainImageLayoutSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.25))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [mainImage])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

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

        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        section.interGroupSpacing = 8

        return section
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPlaylist = SampleFeaturedPlaylists.playlists[indexPath.item]
        performSegue(withIdentifier: "segueShowSongPageViewController", sender: selectedPlaylist)
    }

    // MARK: Private

    private func registerAllNibs() {
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

}
