//
//  ExerciseViewController.swift
//  MomCare
//
//  Created by Nupur on 18/01/25.
//

import UIKit


class ExerciseViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var exercises: Int = 5

    @IBOutlet var exerciseCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        exerciseCollectionView.register(UINib(nibName: "ExerciseDateCell", bundle: nil), forCellWithReuseIdentifier: "ExerciseDate")
        exerciseCollectionView.register(UINib(nibName: "WalkCellMyPlan", bundle: nil), forCellWithReuseIdentifier: "WalkCellMyPlan")
        exerciseCollectionView.register(UINib(nibName: "ExerciseCell", bundle: nil), forCellWithReuseIdentifier: "ExerciseCell")

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
        return exercises + 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseDate", for: indexPath) as? ExerciseDateCellCollectionViewCell

            guard let cell else { fatalError() }
            cell.prepareViewRings()
//            cell.setupRing()
            return cell

        } else if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WalkCellMyPlan", for: indexPath) as? WalkExerciseCollectionViewCell
            guard let cell else { fatalError() }
            return cell

        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseCell", for: indexPath) as? ExerciseCollectionViewCell
            guard let cell else { fatalError("error aa gaya gys") }

            cell.updateElements(segueHandler: segueHandler, popUpHandler: popUpHandler)
            return cell
        }
    }

    func segueHandler() {
        performSegue(withIdentifier: "segueShowBreathingPlayer", sender: nil)
    }
    
    func popUpHandler() {
        ExerciseDetailsViewController(rootViewController: self).show()
    }

    func updateExerciseCardItems(buttonValue: String, completedPercent: Double) {
        if let cell = exerciseCollectionView.cellForItem(at: IndexPath(item: 2, section: 0)) as? ExerciseCollectionViewCell {
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

}
