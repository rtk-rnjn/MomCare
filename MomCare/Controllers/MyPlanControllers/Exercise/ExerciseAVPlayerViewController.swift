import UIKit
import YouTubeiOSPlayerHelper

class ExerciseAVPlayerViewController: UIViewController, YTPlayerViewDelegate {

    // MARK: Internal

    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var restartButton: UIButton!
    @IBOutlet var videoView: UIView!
    var videoURL: String = "https://www.youtube.com/watch?v=UItWltVZZmE"

    override func viewDidLoad() {
        super.viewDidLoad()
        updateGradientBackground()
        setupYouTubePlayer()
        setupButtons()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ytPlayer.frame = videoView.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ytPlayer.stopVideo()
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
            self?.playPauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        }
    }

    // MARK: - YTPlayerViewDelegate Methods
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            playPauseButton.isEnabled = true
            restartButton.isEnabled = true
            playPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            isPlaying = false
        }
    }

    func updateGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds

        let upperColor = UIColor(hex: "#1e0d31")
        let middleColor = UIColor(hex: "#13102f")
        let bottomColor = UIColor(hex: "#0f102e")

        gradientLayer.colors = [
            upperColor.withAlphaComponent(1.0).cgColor,
            middleColor.withAlphaComponent(1.0).cgColor,
            bottomColor.withAlphaComponent(1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            playPauseButton.isEnabled = true

            switch state {
            case .ended:
                playPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
                isPlaying = false

            case .paused:
                playPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
                isPlaying = false

            case .playing:
                playPauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
                isPlaying = true

            case .buffering:
                break
            default:
                break
            }
        }
    }

    // MARK: Private

    private var ytPlayer: YTPlayerView!
    private var isPlaying = false

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
        playPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        playPauseButton.isEnabled = true

        restartButton.setImage(UIImage(systemName: "arrow.counterclockwise.circle.fill"), for: .normal)
        restartButton.isEnabled = true
    }

}
