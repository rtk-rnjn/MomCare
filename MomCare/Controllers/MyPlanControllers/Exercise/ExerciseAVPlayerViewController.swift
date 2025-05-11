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
    @IBOutlet var countdownLabel: UILabel!
    
    // MARK: - Properties
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserver: Any?
    private var isFullScreen = false
    private var controlsTimer: Timer?
    private var countdownTimer: Timer?
    private var hasStartedCountdown = false
    var totalDuration: Int = 5 * 60
    var currentWatchedTime: Int = 0
    
    var onDismiss: ((Int) -> Void)?
    
    var url: URL = URL(string: "https://www.dropbox.com/scl/fi/o9olkxs9z2i2fn0d0ljls/Chair_pose.mp4?rlkey=w4epqhgu3vd2sk8hkrbrq3zs4&st=880ygbe9&raw=1")!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        controlBarView.alpha = 0
        setupPlayer(with: url)
        setupActions()
        setupCountdownLabel()
        
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
        view.addSubview(countdownLabel)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let totalduration = 5 * 60
        let remainingTime = extractSeconds(from: countdownLabel.text ?? "00:00")
        let timeWatched = totalduration - remainingTime
        currentWatchedTime = timeWatched
        
        onDismiss?(currentWatchedTime)
    }

    private func setupPlayer(with url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
            
        playerItem.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)

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
    
    func setupCountdownLabel(){
        Task{
            let isLandscape = await isVideoLandscape()
            if isLandscape {
                countdownLabel.textColor = .white
                countdownLabel.backgroundColor = UIColor.white.withAlphaComponent(0.3)
                updateCountdownLabel()
            } else {
                countdownLabel.textColor = .white
                countdownLabel.backgroundColor =  UIColor.black.withAlphaComponent(0.3)
                updateCountdownLabel()
            }
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
        
        if keyPath == "status", let item = object as? AVPlayerItem {
                if item.status == .readyToPlay {
                    DispatchQueue.main.async {
                        self.controlBarView?.alpha = 1
                    }
                } else if item.status == .failed {
                    dismiss(animated: true, completion: { self.onDismiss?(self.currentWatchedTime)})
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
            
            if !hasStartedCountdown {
                 startCountdown()
                 hasStartedCountdown = true
            }
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
    
    @objc func updateTimer() {
        if totalDuration > 0 {
            totalDuration -= 1
            updateCountdownLabel()
        } else {
            countdownTimer?.invalidate()
            countdownLabel.text = "Done!"
            player?.pause()
            player = nil
            dismiss(animated: true, completion: { self.onDismiss?(self.currentWatchedTime)})
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
    
    func startCountdown() {
        updateCountdownLabel()
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                              target: self,
                                              selector: #selector(updateTimer),
                                              userInfo: nil,
                                              repeats: true)
    }
    
    func updateCountdownLabel() {
        let minutes = totalDuration / 60
        let seconds = totalDuration % 60
        countdownLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    func isVideoLandscape() async -> Bool {
        guard let track = try? await player?.currentItem?.asset.loadTracks(withMediaType: .video).first else {
            return false
        }

        guard let naturalSize = try? await track.load(.naturalSize),
              let preferredTransform = try? await track.load(.preferredTransform) else {
            return false
        }

        let size = naturalSize.applying(preferredTransform)
        return abs(size.width) > abs(size.height)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.playerLayer?.frame = self.playerView.bounds
        })
    }
    
    func extractSeconds(from timeString: String) -> Int {
        let components = timeString.split(separator: ":").compactMap { Int($0) }
        if components.count == 2 {
            let minutes = components[0]
            let seconds = components[1]
            return minutes * 60 + seconds
        }
        return 0
    }

    deinit {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }

        if let playerItem = player?.currentItem {
            playerItem.removeObserver(self, forKeyPath: "status")
            playerItem.removeObserver(self, forKeyPath: "duration")
        }

        NotificationCenter.default.removeObserver(self)
        countdownTimer?.invalidate()
        controlsTimer?.invalidate()
    }
}

