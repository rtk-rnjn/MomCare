//
//  ExerciseAVPlayerViewController.swift
//  MomCare
//
//  Created by Nupur on 17/02/25.
//

import UIKit
import AVKit
import AVFoundation

class ExerciseAVPlayerViewController: UIViewController {

    @IBOutlet var playButton: UIButton!
    @IBOutlet var pauseButton: UIButton!
    @IBOutlet var videoView: UIView!
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playerViewController: AVPlayerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load video from resources
        if let path = Bundle.main.path(forResource: "ExerciseSampleVideo", ofType: "mp4") {
            let videoURL = URL(fileURLWithPath: path)
            setupVideo(url: videoURL)
        }
    }

    func setupVideo(url: URL) {
        // Initialize AVPlayer with the video URL
        player = AVPlayer(url: url)

        // Initialize AVPlayerViewController and set the player
        playerViewController = AVPlayerViewController()
        playerViewController?.player = player

        // Set the player view controller's frame to match the video container
        if let playerViewController {
            playerViewController.view.frame = videoView.bounds
            playerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            // Add the playerViewController's view as a subview of your custom videoView
            videoView.addSubview(playerViewController.view)
        }
    }

    @IBAction func playButtonTapped(_ sender: UIButton) {
        player?.play()

    }

    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        player?.pause()
    }
}
