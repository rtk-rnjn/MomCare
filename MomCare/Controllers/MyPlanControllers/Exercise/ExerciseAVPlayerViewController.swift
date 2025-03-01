

import UIKit
import YouTubeiOSPlayerHelper

class ExerciseAVPlayerViewController: UIViewController, YTPlayerViewDelegate {

    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var restartButton: UIButton!
    @IBOutlet var videoView: UIView!
    private var ytPlayer: YTPlayerView!
    private var isPlaying = false
    
    var videoURL: String = "https://www.youtube.com/watch?v=UItWltVZZmE"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupYouTubePlayer()
        setupButtons()
    }
    
    private func setupYouTubePlayer() {
        ytPlayer = YTPlayerView()
        ytPlayer.delegate = self
        ytPlayer.frame = videoView.bounds
        videoView.addSubview(ytPlayer)
        
        let videoID = extractYouTubeID(from: videoURL)
        ytPlayer.load(withVideoId: videoID)
    }
    
    private func extractYouTubeID(from url: String) -> String {
        if let url = URL(string: url) {
            if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
                if let videoID = queryItems.first(where: { $0.name == "v" })?.value {
                    return videoID
                }
            }
            
            if url.host == "youtu.be" {
                return url.lastPathComponent
            }
        }
        return ""
    }
    
    private func setupButtons() {
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playPauseButton.isEnabled = true

        restartButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        restartButton.isEnabled = true
    }
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        if isPlaying {
            ytPlayer.pauseVideo()
        } else {
            ytPlayer.playVideo()
        }
    }
    
    @IBAction func restartButtonTapped(_ sender: UIButton) {
        ytPlayer.seek(toSeconds: 0, allowSeekAhead: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.ytPlayer.playVideo()
            self?.isPlaying = true
            self?.playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ytPlayer.frame = videoView.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ytPlayer.stopVideo()
    }
    
    // MARK: - YTPlayerViewDelegate Methods
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.playPauseButton.isEnabled = true
            self.restartButton.isEnabled = true
            self.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            self.isPlaying = false
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.playPauseButton.isEnabled = true
            
            switch state {
            case .ended:
                self.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                self.isPlaying = false
            case .paused:
                self.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                self.isPlaying = false
            case .playing:
                self.playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                self.isPlaying = true
            case .buffering:
                break
            default:
                break
            }
        }
    }
}
