//
//  ExerciseViewController.swift
//  MomCare
//
//  Created by Nupur on 18/01/25.
//

import UIKit

class ExerciseViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var ExerciseCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib1 = UINib(nibName: "WalkCellMyPlan", bundle: nil)
        let nib2 = UINib(nibName: "NewExerciseMyPlanCell", bundle: nil)
                
        ExerciseCollectionView.register(nib1, forCellWithReuseIdentifier: "Cell1")
        ExerciseCollectionView.register(nib2, forCellWithReuseIdentifier: "Cell2")
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        ExerciseCollectionView.collectionViewLayout = layout
        layout.itemSize = CGSize(width: 365, height: 170)
        ExerciseCollectionView.collectionViewLayout = layout
        ExerciseCollectionView.showsVerticalScrollIndicator = false
        ExerciseCollectionView.delegate = self
        ExerciseCollectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell1", for: indexPath) as? WalkCellMyPlanCollectionViewCell else {
                return UICollectionViewCell()
            }
                    return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell2", for: indexPath) as? NewExerciseMyPlanCellCollectionViewCell else {
                return UICollectionViewCell()
            }
            return cell
        }
    }

}
