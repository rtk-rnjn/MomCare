import UIKit
import AVKit


class ExerciseAVPlayerViewController: UIViewController {
    
    @IBOutlet var videoContainerView: UIView!
    @IBOutlet var playerView: UIView!
    @IBOutlet var controlBarView: UIView!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var forwardButton: UIButton!
    @IBOutlet var backwardButton: UIButton!
    @IBOutlet var progressSlider: UISlider!
    @IBOutlet var startTimeLabel: UILabel!
    @IBOutlet var endTimeLabel: UILabel!
    
    // MARK: - Properties
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserver: Any?
    private var isFullScreen = false
    var controlsTimer: Timer?
    var url: URL = URL(string: "https://www.dropbox.com/scl/fi/hwyegto90ygyuagxrh29u/full_body_stretch.mp4?rlkey=kr6jqrkchuyxbclj30rexihyp&e=1&st=1losozl7&raw=1")!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer(with: url)
        setupActions()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleControlsVisibility))
        videoContainerView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = playerView.bounds
        
    }
    
    private func setupPlayer(with url: URL) {
        player = AVPlayer(url: url)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        playerLayer?.frame = playerView.bounds
        playerView.layer.addSublayer(playerLayer!)
        
        player?.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
        
        // Add time observer
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
        self?.updateTimeLabel()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "duration", let item = object as? AVPlayerItem {
            let seconds = CMTimeGetSeconds(item.duration)
            if seconds.isFinite {
                endTimeLabel.text = formatTime(seconds)
            }
        }
    }

    
    private func setupActions() {
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        progressSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        forwardButton.addTarget(self, action: #selector(skipForward), for: .touchUpInside)
        backwardButton.addTarget(self, action: #selector(skipBackward), for: .touchUpInside)
    }
        
    // MARK: - Actions
    @objc private func playPauseTapped() {
        if player?.rate == 0 {
            player?.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            player?.pause()
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @objc private func sliderValueChanged() {
        guard let duration = player?.currentItem?.duration else { return }
        let value = Float64(progressSlider.value) * CMTimeGetSeconds(duration)
        let time = CMTime(value: Int64(value), timescale: 1)
        player?.seek(to: time)
    }
    
    @objc private func skipForward() {
        guard let currentTime = player?.currentTime() else { return }
        let newTime = CMTimeAdd(currentTime, CMTime(seconds: 10, preferredTimescale: 1))
        player?.seek(to: newTime)
    }

    @objc private func skipBackward() {
        guard let currentTime = player?.currentTime() else { return }
        var newTime = CMTimeSubtract(currentTime, CMTime(seconds: 10, preferredTimescale: 1))
        if CMTimeGetSeconds(newTime) < 0 {
            newTime = CMTime(seconds: 0, preferredTimescale: 1)
        }
        player?.seek(to: newTime)
    }
    
    @objc private func playerDidFinishPlaying() {
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        player?.seek(to: .zero)
    }
    
    @objc private func toggleControlsVisibility() {
        let shouldShow = controlBarView.alpha == 0
        UIView.animate(withDuration: 0.3) {
            self.controlBarView.alpha = shouldShow ? 1 : 0
        }
        
        if shouldShow {
            resetAutoHideTimer()
        } else {
            controlsTimer?.invalidate()
        }
    }
    
    @objc private func handleOrientationChange() {
            switch UIDevice.current.orientation {
            case .landscapeLeft, .landscapeRight:
                playerLayer?.videoGravity = .resizeAspectFill
            case .portrait, .portraitUpsideDown:
                playerLayer?.videoGravity = .resizeAspect
            default:
                break
            }
        }

    private func resetAutoHideTimer() {
        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            UIView.animate(withDuration: 0.3) {
                self?.controlBarView.alpha = 0
            }
        }
    }

    private func updateTimeLabel() {
        guard let currentTime = player?.currentTime(),
              let duration = player?.currentItem?.duration else { return }
        
        let endTime = duration - currentTime
        
        let currentSeconds = CMTimeGetSeconds(currentTime)
        let durationSeconds = CMTimeGetSeconds(duration)
        let remainingDurationSeconds = CMTimeGetSeconds(endTime)
        
        let currentTimeString = formatTime(currentSeconds)
        let remaingDurationString = formatTime(max(remainingDurationSeconds, 0))
        
        startTimeLabel.text = "\(currentTimeString)"
        endTimeLabel.text = "-\(remaingDurationString)"
        
        progressSlider.value = Float(currentSeconds / durationSeconds)
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    func configure(with videoURL: URL) {
        let playerItem = AVPlayerItem(url: videoURL)
        player?.replaceCurrentItem(with: playerItem)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.playerLayer?.frame = self.playerView.bounds
        })
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    deinit {
        if let playerItem = player?.currentItem,
        let observer = timeObserver {
            playerItem.removeObserver(self, forKeyPath: "duration")
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        NotificationCenter.default.removeObserver(self)
    }
}

