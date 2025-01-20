//

//  ExerciseViewController.swift

//  MomCare

//

//  Created by Nupur on 18/01/25.

//

import UIKit

class ExerciseViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var exercises: Int = 5

    @IBOutlet weak var exerciseCollectionView: UICollectionView!

    override func viewDidLoad() {

        super.viewDidLoad()

        exerciseCollectionView.register(UINib(nibName: "DietDateCell", bundle: nil), forCellWithReuseIdentifier: "DietDate")

        exerciseCollectionView.register(UINib(nibName: "WalkCellMyPlan", bundle: nil), forCellWithReuseIdentifier: "Cell1")

        exerciseCollectionView.register(UINib(nibName: "NewExerciseMyPlanCell", bundle: nil), forCellWithReuseIdentifier: "Cell2")

//        let layout = UICollectionViewFlowLayout()

//        layout.scrollDirection = .vertical

//        ExerciseCollectionView.collectionViewLayout = layout

//        layout.itemSize = CGSize(width: 365, height: 170)

//        ExerciseCollectionView.collectionViewLayout = layout

        exerciseCollectionView.showsVerticalScrollIndicator = false

        exerciseCollectionView.delegate = self

        exerciseCollectionView.dataSource = self

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        // Assuming you have an array of identifiers to determine the type of cell for each indexPath

        switch indexPath.item {

        case 0: 

            // For the first item, use nib file 1

            return CGSize(width: 365, height: 103)

        case 1: 

            // For the second item, use nib file 2

            return CGSize(width: 365, height: 100)

        default: 

            // For subsequent items, use nib file 3

            return CGSize(width: 365, height: 170)

        }

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return 2+exercises

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.item == 0 {

            // Dequeue cell for NibFile1

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DietDate", for: indexPath)

            // Configure the cell

            return cell

        } else if indexPath.item == 1 {

            // Dequeue cell for NibFile2

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell1", for: indexPath)

            // Configure the cell

            return cell

        } else {

            // Dequeue cell for NibFile3

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell2", for: indexPath)

            // Configure the cell

            return cell

        }

    }

}
