//

//  MoodnestViewController.swift

//  MomCare

//

//  Created by Batch - 2  on 16/01/25.

//

import UIKit

class MoodnestViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var pageControl: UIPageControl!

    override func viewDidLoad() {

        super.viewDidLoad()

        collectionView.dataSource = self

        collectionView.delegate = self

        collectionView.showsHorizontalScrollIndicator = false

    }

}

extension MoodnestViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {

        return 1

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return AllMoods.moods.count

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FacesCollectionViewCell", for: indexPath) as! FacesCollectionViewCell

        cell.setup(with: AllMoods.moods[indexPath.item])
        return cell

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = collectionView.frame.width
        let currentPage = Int((collectionView.contentOffset.x + pageWidth / 2) / pageWidth)
        pageControl.currentPage = currentPage
    }
}

extension MoodnestViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: 200, height: 200)

    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let selectedImage = AllMoods.moods[indexPath.item].image

        performSegue(withIdentifier: "ShowGenres", sender: selectedImage)

    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

//        if segue.identifier == "ShowGenres" {

//            if let destinationVC = segue.destination as? GenresPageViewController,

//               let selectedImage = sender as? UIImage {

//                destinationVC.MoodIconImage = selectedImage

//            }

//        }

//    }

}
