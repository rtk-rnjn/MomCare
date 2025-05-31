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

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var outerView: UIView!

    var playlists: [(imageUri: String, label: String)] = []
    var playlistsFetched: Bool = false

    var mood: MoodType?

    override func viewDidLoad() {
        super.viewDidLoad()

        outerView.layer.cornerRadius = 30
        registerAllNibs()

        Task {
            playlists = await ContentHandler.shared.fetchPlaylists(forMood: mood ?? .happy) ?? []
            DispatchQueue.main.async {
                self.playlistsFetched = true
                self.collectionView.reloadData()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SongPageViewController {
            destinationVC.playlist = sender as? (imageUri: String, label: String)
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
            if !playlistsFetched {
                return 6
            }

            return playlists.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellType = MoodNestCollectionViewCellType(rawValue: indexPath.section)
        guard let cellType else { fatalError("Lag jaa gale ke phir yeh haseen raat ho na ho") }

        switch cellType {
        case .mainHeading:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainHeading", for: indexPath) as? MainHeadingCollectionViewCell
            guard let cell else { fatalError("Chura liya hai tumne jo dil ko... Nazar nahi churaana sanam") }

            cell.startShimmer()
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 20

            if !playlistsFetched {
                return cell
            }

            cell.stopShimmer()

            cell.updateElements(with: "Here comes a quote with a beautiful heading")

            return cell

        case .mainImage:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainImage", for: indexPath) as? MainImageCollectionViewCell
            guard let cell else { fatalError("Pyaar hua ikraar hua hai... Pyaar se phir kyoon darta hai dil") }

            cell.startShimmer()
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 20

            if !playlistsFetched {
                return cell
            }

            cell.stopShimmer()

            cell.updateElements(image: nil, label: "Suggested for you")

            return cell

        case .multipleImages:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoodNestMultipleImages", for: indexPath) as? MoodNestMultipleImagesCollectionViewCell
            guard let cell else { fatalError("Yeh shaam mastani, madhosh kiye jaaye") }

            cell.startShimmer()
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 20

            if !playlistsFetched {
                return cell
            }

            cell.stopShimmer()

            let playlist = playlists[indexPath.row]

            Task {
                let image = await UIImage().fetchImage(from: playlist.imageUri)
                DispatchQueue.main.async {
                    cell.updateElements(image: image, label: playlist.label)
                }
            }

            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderCollectionViewCell", for: indexPath) as? SectionHeaderCollectionViewCell

        guard let cell else { fatalError("the sunset is beautiful, isn't it?") }

        cell.startShimmer()
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 20

        if !playlistsFetched {
            return cell
        }

        cell.stopShimmer()

        cell.headerLabel.text = "Featured Playlists"
        cell.headerLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)

        return cell
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
        if !playlistsFetched {
            return
        }

        let selectedPlaylist = playlists[indexPath.item]
        performSegue(withIdentifier: "segueShowSongPageViewController", sender: selectedPlaylist)
    }

    // MARK: Private

    private func registerAllNibs() {
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear

        collectionView.register(UINib(nibName: "MainHeading", bundle: nil), forCellWithReuseIdentifier: "MainHeading")
        collectionView.register(UINib(nibName: "MainImage", bundle: nil), forCellWithReuseIdentifier: "MainImage")
        collectionView.register(UINib(nibName: "MoodNestMultipleImages", bundle: nil), forCellWithReuseIdentifier: "MoodNestMultipleImages")
        collectionView.register(SectionHeaderCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderCollectionViewCell")

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
    }

}
