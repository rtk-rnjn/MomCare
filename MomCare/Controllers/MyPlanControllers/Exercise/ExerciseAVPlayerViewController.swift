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
    
//    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    //    var player: AVPlayer?
    @IBOutlet weak var videoView: UIView!
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.path(forResource: "ExerciseSampleVideo", ofType: "mp4") {
            let videoURL = URL(fileURLWithPath: path)
            setupVideo(url: videoURL)
        }
    }

    func setupVideo(url: URL) {
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        
        if let playerLayer = playerLayer {
            playerLayer.frame = videoView.bounds
            playerLayer.videoGravity = .resizeAspectFill
            videoView.layer.addSublayer(playerLayer)
            
            player?.play()
        }
    }
}
