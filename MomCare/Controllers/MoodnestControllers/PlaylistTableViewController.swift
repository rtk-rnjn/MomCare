import UIKit
import LNPopupController
import AVFoundation
import MediaPlayer

class PlaylistTableViewController: UITableViewController {

    // MARK: Internal

    var songs: [Song] = []
    var songsFetched: Bool = false

    var playlist: (imageUri: String, label: String)?

    var initialTabBarController: InitialTabBarController?
    var songElementsViewController: SongElementsViewController?

    var musicPlayer: MusicPlayerViewController = .init()
    var player: AVPlayer?

    let commandCenter: MPRemoteCommandCenter = .shared()

    var timeObserverToken: Any?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()

        songElementsViewController?.playButton.addTarget(self, action: #selector(playFromSongElementsViewController), for: .touchUpInside)
        songElementsViewController?.shuffleButton.addTarget(self, action: #selector(shuffleFromSongElementsViewController), for: .touchUpInside)

        try? configureAudioSession()
        setupRemoteTransportControls()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !songsFetched {
            return 6
        }
        return songs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "songPageTableViewCell", for: indexPath) as? SongPageTableViewCell else {
            fatalError("Failed to dequeue SongPageTableViewCell")
        }

        cell.songImageView.startShimmer()
        cell.songLabel.startShimmer()
        cell.durationLabel.startShimmer()
        cell.artistOrAlbumLabel.startShimmer()

        if !songsFetched {
            return cell
        }

        cell.songImageView.stopShimmer()
        cell.songLabel.stopShimmer()
        cell.durationLabel.stopShimmer()
        cell.artistOrAlbumLabel.stopShimmer()

        cell.updateElements(with: songs[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setupMusicPlayer(with: songs[indexPath.row])
    }

    func reloadData() {
        Task {
            let songs: [Song] = await ContentHandler.shared.fetchPlaylistSongs(forMood: .happy, playlistName: playlist?.label ?? "") ?? []

            DispatchQueue.main.async {
                self.songs = songs
                self.songsFetched = true

                self.tableView.reloadData()
            }
        }
    }

    @IBAction func unwindToSongPageViewController(_ segue: UIStoryboardSegue) {}

    func setupMusicPlayer(with song: Song) {
        let playBarButton = createBarButtonItem(systemName: "play.fill", action: #selector(playPauseButtonTapped))
        let forwardBarButton = createBarButtonItem(systemName: "forward.fill", action: #selector(forwardButtonTapped))
        let crossBarButton = createBarButtonItem(systemName: "x.circle.fill", action: #selector(crossButtonTapped))

        musicPlayer = MusicPlayerViewController()
        musicPlayer.song = song

        configurePopupItem(for: musicPlayer, song: song, buttons: [playBarButton, forwardBarButton, crossBarButton])
        guard let url = song.url else { return }
        player = AVPlayer(playerItem: AVPlayerItem(url: url))

        observe(player)
        musicPlayer.delegate = self

        initialTabBarController?.presentPopupBar(with: musicPlayer, openPopup: false, animated: true)
    }

    @objc func crossButtonTapped(_ sender: UIButton) {
        initialTabBarController?.dismissPopupBar(animated: true)
        player?.pause()
        player = nil

        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
        }
    }

    func setupRemoteTransportControls() {
        commandCenter.playCommand.addTarget { [unowned self] _ in
            player?.play()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [unowned self] _ in
            player?.pause()
            return .success
        }
    }

    // MARK: Private

    private func configureTableView() {
        tableView.showsVerticalScrollIndicator = false
    }

    private func createBarButtonItem(systemName: String, action: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(systemName: systemName), style: .plain, target: self, action: action)
    }

    private func configurePopupItem(for playerViewController: MusicPlayerViewController, song: Song, buttons: [UIBarButtonItem]) {
        playerViewController.popupItem.title = song.metadata?.title
        playerViewController.popupItem.subtitle = song.metadata?.artist

        Task {
            playerViewController.popupItem.image = await song.image
        }
        playerViewController.popupItem.barButtonItems = buttons

        initialTabBarController?.popupBar.progressViewStyle = .bottom
        initialTabBarController?.popupBar.popupItem?.progress = 0.0
    }

    private func observe(_ player: AVPlayer?) {
        let interval = CMTime(seconds: 0.02, preferredTimescale: 600)
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { time in
            DispatchQueue.main.async {
                guard let currentItem = self.player?.currentItem else { return }

                let duration = CMTimeGetSeconds(currentItem.duration)
                let currentTime = CMTimeGetSeconds(time)
                let progress = duration > 0 ? Float(currentTime / duration) : 0.0

                self.initialTabBarController?.popupBar.popupItem?.progress = progress

                self.musicPlayer.songSlider.value = progress
                self.musicPlayer.startDurationLabel.text = self.getFormattedTime(from: time)
                self.musicPlayer.endDurationLabel.text = self.getFormattedTime(from: currentItem.duration)
            }
        }
    }

    private func getFormattedTime(from time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)

        guard totalSeconds.isFinite && !totalSeconds.isNaN else {
            return "--:--"
        }
        guard totalSeconds >= 0 else {
            return "00:00"
        }

        let seconds = Int(totalSeconds)
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

}

extension PlaylistTableViewController: MusicPlayerDelegate {

    func configureAudioSession() throws {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay, .defaultToSpeaker])
        try AVAudioSession.sharedInstance().setActive(true)
    }

    private func updateNowPlayingInfo(_ song: Song) async {
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: song.metadata?.title ?? "Unknown Title",
            MPMediaItemPropertyArtist: song.metadata?.artist ?? "Unknown Artist"
        ]
        let image = await song.image
        if let image {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in
                return image
            }
        }

        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = try? await player?.currentItem?.asset.load(.duration).seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    @objc func playPauseButtonTapped(_ sender: Any?) {
        let imageName: String
        if player?.timeControlStatus == .playing {
            player?.pause()
            imageName = "play.fill"
        } else {
            player?.play()
            imageName = "pause.fill"
        }

        let config = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .largeTitle))

        musicPlayer.playButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
        initialTabBarController?.popupBar.popupItem?.barButtonItems?.first(where: { $0.action == #selector(playPauseButtonTapped) })?.image = UIImage(systemName: imageName, withConfiguration: config)

        Task {
            guard let song = musicPlayer.song else { return }
            await updateNowPlayingInfo(song)
        }
    }

    @objc func forwardButtonTapped(_ sender: Any?) {
        guard let currentItem = player?.currentItem else { return }
        let currentTime = CMTimeGetSeconds(currentItem.currentTime())
        let duration = CMTimeGetSeconds(currentItem.duration)

        if currentTime + 10 < duration {
            player?.seek(to: CMTime(seconds: currentTime + 10, preferredTimescale: 1))
        } else {
            player?.seek(to: currentItem.duration)
        }
    }

    func backwardButtonTapped(_ sender: Any?) {
        guard let currentItem = player?.currentItem else { return }
        let currentTime = CMTimeGetSeconds(currentItem.currentTime())

        if currentTime - 10 > 0 {
            player?.seek(to: CMTime(seconds: currentTime - 10, preferredTimescale: 1))
        } else {
            player?.seek(to: .zero)
        }
    }

    func durationSliderValueChanged(value: Float) {
        guard let currentItem = player?.currentItem else { return }
        let duration = CMTimeGetSeconds(currentItem.duration)
        let newTime = Double(value) * duration
        player?.seek(to: CMTime(seconds: newTime, preferredTimescale: 1))
    }

    func durationSliderTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: musicPlayer.songSlider)
        let percentage = location.x / musicPlayer.songSlider.bounds.width
        let newTime = Double(percentage) * CMTimeGetSeconds(player?.currentItem?.duration ?? CMTime.zero)
        player?.seek(to: CMTime(seconds: newTime, preferredTimescale: 1))
    }

    func volumeSliderValueChanged(value: Float) {
        player?.volume = value
    }

    func volumeButtonTapped(_ sender: UIButton) {}
}

extension PlaylistTableViewController {
    @objc func playFromSongElementsViewController() {
        setupMusicPlayer(with: songs[0])
    }

    @objc func shuffleFromSongElementsViewController() {
        guard let song = songs.randomElement() else { return }
        setupMusicPlayer(with: song)
    }
}
