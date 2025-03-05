import UIKit
import LNPopupController
import AVFoundation

class PlaylistTableViewController: UITableViewController {

    // MARK: Internal

    var songs: [Song] = []
    var playlist: Playlist!
    var initialTabBarController: InitialTabBarController?
    var songElementsViewController: SongElementsViewController?
    var musicPlayer: MusicPlayer = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()

        songElementsViewController?.playButton.addTarget(self, action: #selector(playFromSongElementsViewController), for: .touchUpInside)
        songElementsViewController?.shuffleButton.addTarget(self, action: #selector(shuffleFromSongElementsViewController), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        songs = playlist.songs
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

    @IBAction func unwindToSongPageViewController(_ segue: UIStoryboardSegue) {}

    func setupMusicPlayer(with song: Song) {
        let playBarButton = createBarButtonItem(systemName: "play.fill", action: #selector(playPauseButtonTapped))
        let forwardBarButton = createBarButtonItem(systemName: "forward.fill", action: #selector(forwardButtonTapped))
        let crossBarButton = createBarButtonItem(systemName: "x.circle.fill", action: #selector(crossButtonTapped))

        musicPlayer = MusicPlayer()
        musicPlayer.song = song
        configurePopupItem(for: musicPlayer, song: song, buttons: [playBarButton, forwardBarButton, crossBarButton])
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

    private func configurePopupItem(for player: MusicPlayer, song: Song, buttons: [UIBarButtonItem]) {
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
        print("WORKS HERE")
    }

    @objc func forwardButtonTapped(_ sender: UIButton) {
        print("WORKS HERE")
    }

    func backwardButtonTapped(_ sender: UIButton) {
        print("WORKS HERE")
    }

    func durationSliderValueChanged(value: Float) {
        print("WORKS HERE")
    }

    func durationSliderTapped(_ gesture: UITapGestureRecognizer) {
        print("WORKS HERE")
    }

    func volumeSliderValueChanged(value: Float) {
        print("WORKS HERE")
    }

    func volumeButtonTapped(_ sender: UIButton) {
        print("WORKS HERE")
    }
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
