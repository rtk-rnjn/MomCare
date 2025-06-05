//
//  ExerciseViewController.swift
//  MomCare
//
//  Created by Nupur on 18/01/25.
//

import UIKit
import AVKit

class ExerciseViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var exercises: [Exercise] = []

    @IBOutlet var weekLabel: UILabel!

    @IBOutlet var collectionView: UICollectionView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let week = MomCareUser.shared.user?.pregancyData?.week ?? 0
        weekLabel.text = "Week \(week)"

        Task {
            self.exercises = await ContentHandler.shared.fetchExercises() ?? []
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

    func exerciseSegueHandler() {
        // present AVKit
    }

    func popUpHandler(_ exercise: Exercise? = nil) {
        guard let exercise else {
            return
        }

        ExerciseDetailsViewController(rootViewController: self, exercise: exercise).show()
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

        return createCell(for: collectionView, at: indexPath, exercise: exercise)
    }

    private func createCell(for collectionView: UICollectionView, at indexPath: IndexPath, exercise: Exercise) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseCell", for: indexPath) as? ExerciseCollectionViewCell else {
            fatalError("error aa gaya gys")
        }
        cell.updateElements(with: exercise, popUpHandler: popUpHandler) {
            switch exercise.type {
            case .breathing:
                self.performSegue(withIdentifier: "segueShowBreathingPlayer", sender: nil)
            default:
                Task {
                    await self.prepareAVPlayer(for: exercise)
                }
            }
        }
        return cell
    }

}

extension ExerciseViewController: AVPlayerViewControllerDelegate {
    func prepareAVPlayer(for exercise: Exercise) async {
        guard let uri = await exercise.uri, let url = URL(string: uri) else {
            return
        }
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.modalPresentationStyle = .fullScreen
        playerViewController.delegate = self
        playerViewController.title = exercise.name
        DispatchQueue.main.async {
            self.present(playerViewController, animated: true) {
                playerViewController.player?.play()
            }
        }
    }
}
