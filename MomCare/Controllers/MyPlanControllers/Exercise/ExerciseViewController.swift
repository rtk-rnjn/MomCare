//
//  ExerciseViewController.swift
//  MomCare
//
//  Created by Nupur on 18/01/25.
//

import UIKit
import AVKit

class ExerciseViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: Lifecycle

    deinit {
        timeControlStatusObservation?.invalidate()
        timeControlStatusObservation = nil
    }

    // MARK: Internal

    var selectedExercise: Exercise?
    var myPlanViewController: MyPlanViewController?

    var dataFetched = false

    @IBOutlet var weekLabel: UILabel!

    @IBOutlet var collectionView: UICollectionView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let week = MomCareUser.shared.user?.pregancyData?.week ?? 0
        weekLabel.text = "Week \(week)"

        Task {
            await fetchExercises()
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

    func fetchExercises() async {
        let exists = MomCareUser.shared.user?.exercises != nil && !(MomCareUser.shared.user?.exercises.isEmpty ?? true)
        if !exists {
            let exercises = await ContentHandler.shared.fetchExercises() ?? []
            MomCareUser.shared.user?.exercises = exercises
        }
        DispatchQueue.main.async {
            self.myPlanViewController?.exercisesLoaded = true
            self.dataFetched = true
            self.collectionView.reloadData()
        }
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
        if !dataFetched {
            return 6
        }
        return (MomCareUser.shared.user?.exercises.count ?? 0) + 2
    }

    func popUpHandler(_ exercise: Exercise? = nil) {
        guard let exercise else {
            return
        }

        ExerciseDetailsViewController(rootViewController: self, exercise: exercise).show()
    }

    // MARK: Private

    private var timeControlStatusObservation: NSKeyValueObservation?
    private var player: AVPlayer?
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
        cell.startShimmer()
        if !dataFetched {
            return cell
        }
        cell.stopShimmer()

        cell.prepareViewRings()
        return cell
    }

    private func createWalkCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WalkCellMyPlan", for: indexPath) as? WalkExerciseCollectionViewCell else {
            fatalError()
        }
        cell.startShimmer()
        if !dataFetched {
            return cell
        }
        cell.stopShimmer()

        Task {
            await HealthKitHandler.shared.readStepCount { steps in
                DispatchQueue.main.async {
                    cell.steps = steps
                    cell.updateElements()
                }
            }
        }
        return cell
    }

    private func createExerciseCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseCell", for: indexPath) as? ExerciseCollectionViewCell else {
            fatalError("error aa gaya gys")
        }
        cell.startShimmer()
        if !dataFetched {
            return cell
        }
        cell.stopShimmer()

        let adjustedIndex = indexPath.item - 2
        guard let exercises = MomCareUser.shared.user?.exercises else {
            fatalError()
        }

        let exercise = exercises[adjustedIndex]

        cell.updateElements(with: exercise, popUpHandler: popUpHandler) {
            self.selectedExercise = exercise
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
        player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.modalPresentationStyle = .fullScreen
        playerViewController.delegate = self
        playerViewController.title = exercise.name
        DispatchQueue.main.async {
            self.present(playerViewController, animated: true) {
                if exercise.durationCompleted > 0 {
                    let seekTime = CMTime(seconds: exercise.durationCompleted, preferredTimescale: 1)
                    playerViewController.player?.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
                } else {
                    playerViewController.player?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
                }
                playerViewController.player?.play()
            }
        }

        timeControlStatusObservation = player?.observe(\.timeControlStatus, options: [.old, .new]) { player, _ in
            if player.timeControlStatus == .paused {
                DispatchQueue.main.async {
                    self.updateExerciseStats()
                    self.collectionView.reloadData()
                }
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)

    }

    @objc func playerDidFinishPlaying(note: NSNotification) {
        updateExerciseStats()
    }

    func updateExerciseStats() {
        guard let exercises = MomCareUser.shared.user?.exercises, let selectedExercise else {
            return
        }

        for index in exercises.indices where exercises[index].name == selectedExercise.name {
            guard
                let totalDuration = player?.currentItem?.duration.seconds,
                let durationCompleted = player?.currentTime().seconds
            else {
                return
            }

            MomCareUser.shared.user?.exercises[index].duration = totalDuration
            MomCareUser.shared.user?.exercises[index].durationCompleted = durationCompleted
        }
    }

}
