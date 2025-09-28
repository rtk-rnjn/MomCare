//
//  MoodnestViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 17/01/25.
//

import UIKit

class MoodNestViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: Internal

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var outerView: UIView!

    var playlists: [(imageUri: String, label: String)] = []
    var playlistsFetched: Bool = false

    var mood: MoodType?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .CustomColors.mutedRaspberry
        outerView.layer.cornerRadius = 30
        registerAllNibs()

        Task {
            guard let mood else {
                fatalError("Mood is not set before fetching playlists")
            }
            playlists = await ContentHandler.shared.fetchPlaylists(forMood: mood) ?? []
            DispatchQueue.main.async {
                self.playlistsFetched = true
                self.collectionView.reloadData()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? SongPageViewController {
            viewController.playlist = sender as? (imageUri: String, label: String)
            viewController.mood = mood
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0, 1:
            return 1

        case 2:
            if !playlistsFetched {
                return 6
            }

            return playlists.count

        default:
            fatalError("Unexpected section index")
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            return configureMainHeadingCell(collectionView, indexPath)
        case 1, 2:
            return configurePlaylistCollectionViewCell(collectionView, indexPath)
        default:
            fatalError("Unexpected section index")
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
        cell.headerLabel.font = UIFont.preferredFont(forTextStyle: .title2)

        return cell
    }

    func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let section: NSCollectionLayoutSection
            switch sectionIndex {

            case 0:
                section = self.generateMainHeadingLayout()

            case 1:
                section = self.generateSuggestedPlaylistLayout()

            case 2:
                section = self.generatePlaylistLayout()

                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top
                )

                section.boundarySupplementaryItems = [header]

            default:
                fatalError("Unexpected section index")
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

    func generateSuggestedPlaylistLayout() -> NSCollectionLayoutSection {
        let mainImageLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let mainImage = NSCollectionLayoutItem(layoutSize: mainImageLayoutSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.25))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [mainImage])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

        return section
    }

    func generatePlaylistLayout() -> NSCollectionLayoutSection {
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

        let cell = collectionView.cellForItem(at: indexPath) as? PlaylistCollectionViewCell

        performSegue(withIdentifier: "segueShowSongPageViewController", sender: cell?.playlist)
    }

    // MARK: Private

    private func configureMainHeadingCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainHeading", for: indexPath) as? MainHeadingCollectionViewCell else {
            fatalError("Chura liya hai tumne jo dil ko... Nazar nahi churaana sanam")
        }

        styleCell(cell)

        if !playlistsFetched {
            cell.startShimmer()
            return cell
        }

        cell.stopShimmer()
        fetchAndUpdateQuote(for: cell)

        return cell
    }

    private func configurePlaylistCollectionViewCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Playlist", for: indexPath) as? PlaylistCollectionViewCell else {
            fatalError("Yeh shaam mastani, madhosh kiye jaaye")
        }

        styleCell(cell)

        if !playlistsFetched {
            cell.startShimmer()
            return cell
        }

        cell.stopShimmer()

        let playlist = indexPath.section == 1 ? playlists.randomElement() : playlists[indexPath.row]
        let applyLargeTitle = indexPath.section == 1
        cell.updateElements(with: playlist, applyLargeTitle: applyLargeTitle)

        return cell
    }

    private func styleCell(_ cell: UICollectionViewCell) {
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 20
    }

    private func fetchAndUpdateQuote(for cell: MainHeadingCollectionViewCell) {
        Task {
            guard let mood else { return }
            guard let quote = await ContentHandler.shared.fetchQuotes(for: mood) else { return }

            DispatchQueue.main.async {
                cell.updateElements(with: quote)
            }
        }
    }

    private func registerAllNibs() {
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear

        collectionView.register(UINib(nibName: "MainHeading", bundle: nil), forCellWithReuseIdentifier: "MainHeading")
        collectionView.register(UINib(nibName: "Playlist", bundle: nil), forCellWithReuseIdentifier: "Playlist")
        collectionView.register(SectionHeaderCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderCollectionViewCell")

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
    }

}
