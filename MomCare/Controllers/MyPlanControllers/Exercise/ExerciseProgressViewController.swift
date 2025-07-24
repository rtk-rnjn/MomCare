//
//  ExerciseProgressViewController.swift
//  MomCare
//
//  Created by Aryan Singh on 23/07/25.
//

import SwiftUI
import AVKit
import AVFoundation

class ExerciseProgressViewController: UIHostingController<ExerciseProgressView> {

    // MARK: Lifecycle

    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: ExerciseProgressView())
    }

    // MARK: Internal

    var player: AVPlayer?
    var timeControlStatusObservation: Any?
    var selectedExercise: Exercise?

    override func viewDidLoad() {
        super.viewDidLoad()

        rootView.delegate = self
    }

    func readStepCount() async -> (current: Double, target: Double) {
        let count = await HealthKitHandler.shared.readStepCount()
        let goal = Utils.getStepGoal(week: MomCareUser.shared.user?.pregancyData?.week ?? 1)

        return (Double(count), Double(goal))
    }

    func segueToBreathingPlayer() {
        performSegue(withIdentifier: "segueShowBreathingPlayerViewController", sender: nil)
    }

    func fetchExercises() async -> [Exercise] {
        let exists = MomCareUser.shared.user?.exercises != nil && !(MomCareUser.shared.user?.exercises.isEmpty ?? true)
        if !exists {
            let exercises = await ContentHandler.shared.fetchExercises() ?? []
            MomCareUser.shared.user?.exercises = exercises
        }

        return MomCareUser.shared.user?.exercises ?? []
    }

    func play(exercise: Exercise) async {
        await prepareAVPlayer(for: exercise)
    }
}

extension ExerciseProgressViewController: AVPlayerViewControllerDelegate {
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
        guard let exercises = MomCareUser.shared.user?.exercises else {
            return
        }

        for index in exercises.indices where exercises[index].name == selectedExercise?.name {
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowBreathingPlayerViewController", let destinationViewController = segue.destination as? BreathingPlayerViewController {
            destinationViewController.exerciseProgressViewController = self
        }
    }

    func triggerRefresh() {
        var newView = ExerciseProgressView()
        newView.delegate = self

        rootView = newView
    }
}
