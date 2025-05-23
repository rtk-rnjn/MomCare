import UIKit
import LNPopupController
import AVFoundation

class PlaylistTableViewController: UITableViewController {

    // MARK: Internal

    var songs: [Song] = []
    var playlist: Playlist!
    var initialTabBarController: InitialTabBarController?
    var songElementsViewController: SongElementsViewController?
    var musicPlayer: MusicPlayerViewController = .init()
    var player: AVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()

        songElementsViewController?.playButton.addTarget(self, action: #selector(playFromSongElementsViewController), for: .touchUpInside)
        songElementsViewController?.shuffleButton.addTarget(self, action: #selector(shuffleFromSongElementsViewController), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        songs = playlist.songs

        setSongs()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "songPageTableViewCell", for: indexPath) as? SongPageTableViewCell else {
            fatalError("Failed to dequeue SongPageTableViewCell")
        }
        cell.updateElements(with: songs[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setupMusicPlayer(with: songs[indexPath.row])
    }

    func setSongs() {
        let mood = playlist.forMood!

        Task {
            let links: [String] = await ContentHandler.shared.fetchTuneNames(tuneType: mood) ?? []
            var songs: [Song] = []
            for link in links {
                let songUri = await ContentHandler.shared.fetchTune(tuneType: mood, category: "", fileName: link)

                let name = link.components(separatedBy: ".").first ?? ""
                let song = Song(name: name, artist: "Unknown Artist", duration: 100, uri: songUri?.uri)

                songs.append(song)
            }

            DispatchQueue.main.async {
                self.songs = songs
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
        musicPlayer.delegate = self

        initialTabBarController?.presentPopupBar(with: musicPlayer, animated: true)
    }

    @objc func crossButtonTapped(_ sender: UIButton) {
        initialTabBarController?.dismissPopupBar(animated: true)
    }

    // MARK: Private

    private func configureTableView() {
        tableView.showsVerticalScrollIndicator = false
    }

    private func createBarButtonItem(systemName: String, action: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(systemName: systemName), style: .plain, target: self, action: action)
    }

    private func configurePopupItem(for player: MusicPlayerViewController, song: Song, buttons: [UIBarButtonItem]) {
        player.popupItem.title = song.name
        player.popupItem.subtitle = song.artist
        player.popupItem.progress = 0.34
        player.popupItem.image = song.image
        player.popupItem.barButtonItems = buttons

        player.popupItem.accessibilityUserInputLabels = ["Play", "Pause", "Next", "Previous"]
        player.popupItem.accessibilityHint = "Tap to open the player"
        player.popupItem.accessibilityLabel = "Playing now"
        player.popupItem.accessibilityValue = "\(song.name) by \(song.artist)"
    }

}

extension PlaylistTableViewController: MusicPlayerDelegate {
    @objc func playPauseButtonTapped(_ sender: UIButton) {
        if player?.timeControlStatus == .playing {
            player?.pause()
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            player?.play()
            sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }

    @objc func forwardButtonTapped(_ sender: UIButton) {
        guard let currentItem = player?.currentItem else { return }
        let currentTime = CMTimeGetSeconds(currentItem.currentTime())
        let duration = CMTimeGetSeconds(currentItem.duration)

        if currentTime + 10 < duration {
            player?.seek(to: CMTime(seconds: currentTime + 10, preferredTimescale: 1))
        } else {
            player?.seek(to: currentItem.duration)
        }
    }

    func backwardButtonTapped(_ sender: UIButton) {
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
