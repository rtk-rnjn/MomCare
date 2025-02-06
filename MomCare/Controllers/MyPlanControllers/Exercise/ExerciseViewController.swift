//
//  ExerciseViewController.swift
//  MomCare
//
//  Created by Nupur on 18/01/25.
//

import UIKit

class ExerciseViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NewExerciseMyPlanCellDelegate {
    func didTapInfoButton() {
        showInfoCard()
    }
    
    var exercises: Int = 5

    @IBOutlet var exerciseCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exerciseCollectionView.register(UINib(nibName: "ExerciseDateCell", bundle: nil), forCellWithReuseIdentifier: "ExerciseDate")
        exerciseCollectionView.register(UINib(nibName: "WalkCellMyPlan", bundle: nil), forCellWithReuseIdentifier: "Cell1")
        exerciseCollectionView.register(UINib(nibName: "NewExerciseMyPlanCell", bundle: nil), forCellWithReuseIdentifier: "Cell2")

        exerciseCollectionView.showsVerticalScrollIndicator = false

        exerciseCollectionView.delegate = self
        exerciseCollectionView.dataSource = self
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.item {
        case 0:
            return CGSize(width: 365, height: 103)

        case 1:
            return CGSize(width: 365, height: 100)

        default:
            return CGSize(width: 365, height: 170)
        }

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return 2+exercises

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.item == 0 {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseDate", for: indexPath)

        } else if indexPath.item == 1 {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "Cell1", for: indexPath)

        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell2", for: indexPath) as? NewExerciseMyPlanCellCollectionViewCell
            guard let cell else { fatalError("error aa gaya gys") }

            cell.delegate = self
            cell.updateElements(with: segueHandler)
            return cell
        }
    }
    

    func segueHandler() {
        performSegue(withIdentifier: "segueShowBreathingPlayer", sender: nil)
    }

    func updateExerciseCardItems(buttonValue: String, completedPercent: Double) {
        if let cell = exerciseCollectionView.cellForItem(at: IndexPath(item: 2, section: 0)) as? NewExerciseMyPlanCellCollectionViewCell {
            cell.exerciseStartButton.setTitle(buttonValue, for: .normal)
            cell.exerciseCompletionPercentage.text = "\(Int(completedPercent))% completed"
        }
    }

    @IBAction func unwindToMyPlanExercisePage(segue: UIStoryboardSegue) {
        if let sourceVC = segue.source as? BreathingPlayerViewController {
            if sourceVC.completedPercentage < 100 {
                updateExerciseCardItems(buttonValue: "Continue", completedPercent: sourceVC.completedPercentage)
            }
        }
    }
    
    func showInfoCard() {
            dimmedBackgroundView.isHidden = false
            cardView.isHidden = false

            dimmedBackgroundView.alpha = 0
            cardView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

            UIView.animate(withDuration: 0.3, animations: {
                self.dimmedBackgroundView.alpha = 1
                self.cardView.transform = .identity
            })
    }
}

