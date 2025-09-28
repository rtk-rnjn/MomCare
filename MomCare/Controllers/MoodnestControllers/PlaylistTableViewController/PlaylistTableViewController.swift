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

    var currentPlayingIndex: IndexPath?
    var mood: MoodType?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()

        setupInitialUI()

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

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func setupInitialUI() {
        songElementsViewController?.playPauseButton.addTarget(self, action: #selector(playPauseFromSongElementsViewController), for: .touchUpInside)
        songElementsViewController?.shuffleButton.addTarget(self, action: #selector(shuffleFromSongElementsViewController), for: .touchUpInside)

        songElementsViewController?.playPauseButton.isEnabled = false
        songElementsViewController?.shuffleButton.isEnabled = false
    }

    func reloadData() {
        Task {
            guard let mood else {
                fatalError()
            }
            let songs: [Song] = await ContentHandler.shared.fetchPlaylistSongs(forMood: mood, playlistName: playlist?.label ?? "") ?? []

            DispatchQueue.main.async {
                self.songs = songs
                self.songsFetched = true

                self.tableView.reloadData()

                if !self.songs.isEmpty {
                    self.songElementsViewController?.playPauseButton.isEnabled = true
                    self.songElementsViewController?.shuffleButton.isEnabled = true
                }

                self.songElementsViewController?.playPauseButton.stopShimmer()
                self.songElementsViewController?.shuffleButton.stopShimmer()
            }
        }
    }

    @IBAction func unwindToSongPageViewController(_ segue: UIStoryboardSegue) {}

    func setupMusicPlayer(with song: Song) {

        let barButtons: [UIBarButtonItem] = [
            createBarButtonItem(systemName: "play.fill", action: #selector(playPauseButtonTapped)),
            createBarButtonItem(systemName: "forward.fill", action: #selector(forwardButtonTapped)),
            createBarButtonItem(systemName: "x.circle.fill", action: #selector(crossButtonTapped))
        ]

        musicPlayer = MusicPlayerViewController()
        musicPlayer.song = song
        musicPlayer.delegate = self

        MusicPlayerHandler.shared.interfaceUpdater = { status in
            switch status {
            case .playing:
                DispatchQueue.main.async {
                    self.updatePlayPauseUI(setImage: "pause.fill")
                }

            case .paused:
                DispatchQueue.main.async {
                    self.updatePlayPauseUI(setImage: "play.fill")
                }

            default:
                break
            }
        }

        configurePopupItem(for: musicPlayer, song: song, buttons: barButtons)

        MusicPlayerHandler.shared.preparePlayer(song: song, periodicUpdater: periodicUpdater, songFinishedCompletionHandler: prepareNextIfPossible) {
            DispatchQueue.main.async {
                self.initialTabBarController?.presentPopupBar(with: self.musicPlayer, openPopup: false, animated: true) {
                    self.playPauseButtonTapped(nil)
                }
            }
        }
    }

    @objc func crossButtonTapped(_ sender: UIButton) {
        initialTabBarController?.dismissPopupBar(animated: true)
        MusicPlayerHandler.shared.stop()
    }

    @objc func songDidFinishPlaying(notification: Notification) {
        MusicPlayerHandler.shared.stop()
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
            MusicPlayerHandler.shared.stop()
        }
    }

    // MARK: Private

    private func periodicUpdater(time: CMTime) {
        guard let currentItem = MusicPlayerHandler.shared.player?.currentItem else { return }

        let duration = CMTimeGetSeconds(currentItem.duration)
        let currentTime = CMTimeGetSeconds(time)
        let progress = duration > 0 ? Float(currentTime / duration) : 0.0

        initialTabBarController?.popupBar.popupItem?.progress = progress

        musicPlayer.songSlider.value = progress
        musicPlayer.startDurationLabel.text = getFormattedTime(from: time)
        musicPlayer.endDurationLabel.text = getFormattedTime(from: currentItem.duration)
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
        initialTabBarController?.popupContentView.popupCloseButtonStyle = .chevron
        initialTabBarController?.popupInteractionStyle = .snap
        initialTabBarController?.popupBar.popupItem?.progress = 0.0
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
    @objc func playPauseFromSongElementsViewController() {
        guard let song = songs.first else { return }

        if MusicPlayerHandler.shared.player == nil {
            setupMusicPlayer(with: song)
        } else {
            playPauseButtonTapped(songElementsViewController?.playPauseButton)
        }
    }

    @objc func shuffleFromSongElementsViewController() {
        if MusicPlayerHandler.shared.player == nil {
            guard let song = songs.randomElement() else { return }
            setupMusicPlayer(with: song)
        } else {
            MusicPlayerHandler.shared.stop()
            return shuffleFromSongElementsViewController()
        }
    }
}
