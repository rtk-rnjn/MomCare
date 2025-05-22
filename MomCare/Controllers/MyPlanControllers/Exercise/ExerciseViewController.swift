//
//  ExerciseViewController.swift
//  MomCare
//
//  Created by Nupur on 18/01/25.
//

import UIKit

class ExerciseViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var exercises: [Exercise] = []

    @IBOutlet var weekLabel: UILabel!

    @IBOutlet var collectionView: UICollectionView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let week = MomCareUser.shared.user?.pregancyData?.week ?? 0
        weekLabel.text = "Week \(week)"

        Task {
            self.exercises = await ContentHandler.shared.fetchExercise() ?? []
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "ExerciseDateCell", bundle: nil), forCellWithReuseIdentifier: "ExerciseDate")
        collectionView.register(UINib(nibName: "WalkCellMyPlan", bundle: nil), forCellWithReuseIdentifier: "WalkCellMyPlan")

        collectionView.register(UINib(nibName: "ExerciseCell", bundle: nil), forCellWithReuseIdentifier: "ExerciseCell")
        collectionView.register(UINib(nibName: "BreathingCell", bundle: nil), forCellWithReuseIdentifier: "BreathingCell")

        collectionView.showsVerticalScrollIndicator = false

        collectionView.delegate = self
        collectionView.dataSource = self

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
        return exercises.count + 2
    }

    func breathingSegueHandler() {
        performSegue(withIdentifier: "segueShowBreathingPlayer", sender: nil)
    }

    func exerciseSegueHandler() {
        // present AVKit
    }

    func popUpHandler(_ exercise: Exercise? = nil) {
        ExerciseDetailsViewController(rootViewController: self).show(exercise)
    }
}

extension ExerciseViewController {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            return createDateCell(for: collectionView, at: indexPath)
        case 1:
            return createWalkCell(for: collectionView, at: indexPath)
        default:
            return createExerciseCell(for: collectionView, at: indexPath)
        }
    }

    private func createDateCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseDate", for: indexPath) as? ExerciseDateCellCollectionViewCell else {
            fatalError()
        }
        cell.prepareViewRings()
        return cell
    }

    private func createWalkCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WalkCellMyPlan", for: indexPath) as? WalkExerciseCollectionViewCell else {
            fatalError()
        }
        HealthKitHandler.shared.readStepCount { steps in
            DispatchQueue.main.async {
                cell.steps = steps
                cell.updateElements()
            }
        }
        return cell
    }

    private func createExerciseCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let adjustedIndex = indexPath.item - 2
        guard !exercises.isEmpty, adjustedIndex >= 0, adjustedIndex < exercises.count else {
            return UICollectionViewCell()
        }

        let exercise = exercises[adjustedIndex]

        switch exercise.exerciseType {
        case .breathing:
            return createBreathingCell(for: collectionView, at: indexPath, exercise: exercise)
        case .stretching:
            return createStretchingCell(for: collectionView, at: indexPath, exercise: exercise)
        case .yoga:
            return UICollectionViewCell()
        }
    }

    private func createBreathingCell(for collectionView: UICollectionView, at indexPath: IndexPath, exercise: Exercise) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BreathingCell", for: indexPath) as? BreathingCollectionViewCell else {
            fatalError()
        }
        cell.updateElements(with: exercise, segueHandler: breathingSegueHandler, popUpHandler: popUpHandler)
        return cell
    }

    private func createStretchingCell(for collectionView: UICollectionView, at indexPath: IndexPath, exercise: Exercise) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseCell", for: indexPath) as? ExerciseCollectionViewCell else {
            fatalError("error aa gaya gys")
        }
        cell.updateElements(with: exercise, segueHandler: exerciseSegueHandler, popUpHandler: popUpHandler)
        return cell
    }

}
