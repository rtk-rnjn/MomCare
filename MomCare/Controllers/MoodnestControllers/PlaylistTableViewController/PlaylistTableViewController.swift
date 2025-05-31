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

    var currentPlayingIndex: IndexPath?
    var currentPlayingSong: Song?

    let commandCenter: MPRemoteCommandCenter = .shared()

    var timeObserverToken: Any?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()

        setupInitialUI()

        try? configureAudioSession()
        setupRemoteTransportControls()

        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return songsFetched && indexPath.row < songs.count
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard songsFetched, sourceIndexPath.row < songs.count, destinationIndexPath.row < songs.count else {
            return
        }

        let movedSong = songs.remove(at: sourceIndexPath.row)
        songs.insert(movedSong, at: destinationIndexPath.row)

        currentPlayingIndex = destinationIndexPath
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
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
        if !songsFetched {
            return
        }
        let song = songs[indexPath.row]

        setupMusicPlayer(with: song)
        currentPlayingIndex = indexPath
        currentPlayingSong = song

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func setupInitialUI() {
        songElementsViewController?.playButton.addTarget(self, action: #selector(playFromSongElementsViewController), for: .touchUpInside)
        songElementsViewController?.shuffleButton.addTarget(self, action: #selector(shuffleFromSongElementsViewController), for: .touchUpInside)

        songElementsViewController?.playButton.isEnabled = false
        songElementsViewController?.shuffleButton.isEnabled = false

        songElementsViewController?.playButton.startShimmer()
        songElementsViewController?.shuffleButton.startShimmer()
    }

    func reloadData() {
        Task {
            let songs: [Song] = await ContentHandler.shared.fetchPlaylistSongs(forMood: .happy, playlistName: playlist?.label ?? "") ?? []

            DispatchQueue.main.async {
                self.songs = songs
                self.songsFetched = true

                self.tableView.reloadData()

                if !self.songs.isEmpty {
                    self.songElementsViewController?.playButton.isEnabled = true
                    self.songElementsViewController?.shuffleButton.isEnabled = true
                }

                self.songElementsViewController?.playButton.stopShimmer()
                self.songElementsViewController?.shuffleButton.stopShimmer()
            }
        }
    }

    @IBAction func unwindToSongPageViewController(_ segue: UIStoryboardSegue) {}

    func setupMusicPlayer(with song: Song) {
        discardPreviousPlayer()
        guard let url = song.url else { return }

        let barButtons: [UIBarButtonItem] = [
            createBarButtonItem(systemName: "play.fill", action: #selector(playPauseButtonTapped)),
            createBarButtonItem(systemName: "forward.fill", action: #selector(forwardButtonTapped)),
            createBarButtonItem(systemName: "x.circle.fill", action: #selector(crossButtonTapped))
        ]

        musicPlayer = MusicPlayerViewController()
        musicPlayer.song = song
        musicPlayer.delegate = self

        configurePopupItem(for: musicPlayer, song: song, buttons: barButtons)

        player = AVPlayer(url: url)

        startObserving(player)

        initialTabBarController?.presentPopupBar(with: musicPlayer, openPopup: true, animated: true) {
            self.player?.play()
            DispatchQueue.main.async { self.updatePlayPauseUI() }
        }
    }

    @objc func crossButtonTapped(_ sender: UIButton) {
        initialTabBarController?.dismissPopupBar(animated: true)
        player?.pause()
        player = nil
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
        }
        timeObserverToken = nil
        currentPlayingIndex = nil
    }

    @objc func songDidFinishPlaying(notification: Notification) {
        guard let currentItem = notification.object as? AVPlayerItem else { return }
        if currentItem == player?.currentItem {
            initialTabBarController?.dismissPopupBar(animated: true)
            player?.pause()
            player = nil
            timeObserverToken = nil
        }

        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: currentItem)

        prepareNextIfPossible()
    }

    func prepareNextIfPossible() {
        guard let currentIndex = currentPlayingIndex else { return }
        let nextIndex = IndexPath(row: currentIndex.row + 1, section: currentIndex.section)

        if nextIndex.row < songs.count {
            setupMusicPlayer(with: songs[nextIndex.row])
            currentPlayingIndex = nextIndex
        } else {
            initialTabBarController?.dismissPopupBar(animated: true)
            player?.pause()
            player = nil
            timeObserverToken = nil
            currentPlayingIndex = nil
        }
    }

    // MARK: Private

    private func discardPreviousPlayer() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
        }
        timeObserverToken = nil
        player?.pause()
        player = nil
        currentPlayingIndex = nil
    }

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

    private func startObserving(_ player: AVPlayer?) {
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

        NotificationCenter.default.addObserver(self, selector: #selector(songDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
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

extension PlaylistTableViewController {
    @objc func playFromSongElementsViewController() {}

    @objc func shuffleFromSongElementsViewController() {
        if player == nil {
            guard let song = songs.randomElement() else { return }
            setupMusicPlayer(with: song)
        } else {
            player?.pause()
            player = nil
            return shuffleFromSongElementsViewController()
        }
    }
}
