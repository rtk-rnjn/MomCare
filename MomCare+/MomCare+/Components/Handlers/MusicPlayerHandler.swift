import AVFoundation
import Combine
import MediaPlayer
import SwiftUI
import UIKit

@MainActor
final class MusicPlayerHandler: ObservableObject {

    // MARK: Lifecycle

    init() {
        configureRemoteTransportControls()

        if let savedPlaylistData = UserDefaults.standard.data(forKey: "loadedPlaylist"),
           let savedPlaylist = try? JSONDecoder().decode([SongModel].self, from: savedPlaylistData) {
            playlist = savedPlaylist
        }

        if let savedCurrentSongIndex = UserDefaults.standard.integer(forKey: "currentSongIndex") as Int? {
            currentSongIndex = savedCurrentSongIndex
        }

        if let savedImageData = UserDefaults.standard.data(forKey: "currentSongUIImage"),
           let savedImage = UIImage(data: savedImageData) {
            currentSongUIImage = savedImage
        }

        if let song = playlist[safe: currentSongIndex] {
            Task {
                self.player = await self.prepareAVPlayer(with: song)
                startObserving()
            }
        }
    }

    // MARK: Internal

    private(set) var player: AVPlayer?
    @Published var playbackProgress: Double = 0.0

    var isPlaying: Bool {
        player?.timeControlStatus == .playing
    }

    @Published var playlist: [SongModel] = [] {
        didSet {
            let key = "loadedPlaylist"
            if let encoded = try? JSONEncoder().encode(playlist) {
                UserDefaults.standard.set(encoded, forKey: key)
            }
        }
    }

    @Published var currentSongIndex: Int = 0 {
        didSet { UserDefaults.standard.set(currentSongIndex, forKey: "currentSongIndex") }
    }

    @Published var currentSongUIImage: UIImage? {
        didSet {
            if let data = currentSongUIImage?.jpegData(compressionQuality: 0.8) {
                UserDefaults.standard.set(data, forKey: "currentSongUIImage")
            }
        }
    }

    var currentSong: SongModel? {
        playlist[safe: currentSongIndex]
    }

    var totalDuration: Double {
        if let duration = player?.currentItem?.duration, duration.isNumeric {
            duration.seconds
        } else {
            1
        }
    }

    func preparePlaylistAndPlay(_ playlist: PlaylistModel, startingWith index: Int = 0) {
        self.playlist = playlist.songs
        currentSongIndex = index
        if let song = playlist.songs[safe: index] {
            play(song: song)
        }
    }

    func skipToNext() {
        play(song: adjacentSong(offset: 1))
    }

    func skipToPrevious() {
        play(song: adjacentSong(offset: -1))
    }

    func togglePlayPause() -> Bool {
        guard let player else { return false }

        if player.timeControlStatus == .playing {
            player.pause()
        } else {
            player.play()
        }

        return player.timeControlStatus == .playing
    }

    func stop() {
        player?.pause()
        discardPlayer()
    }

    func seek(by seconds: Double) {
        guard let player else { return }
        let newTime = CMTime(
            seconds: seconds,
            preferredTimescale: CMTimeScale(NSEC_PER_SEC)
        )
        player.seek(to: newTime)
    }

    // MARK: Private

    private var timeObserverToken: Any?

    private func play(song: SongModel?, discardPrevious: Bool = true) {
        guard let song else { return }

        Task {
            guard let url = await song.url, let image = await song.image else { return }

            if discardPrevious {
                discardPlayer()
            }

            try? startAudioSession()

            currentSongUIImage = image

            player = prepareAVPlayer(with: url)

            startObserving()
            player?.play()
        }
    }

    private func prepareAVPlayer(with songUri: URL) -> AVPlayer {
        let playerItem = AVPlayerItem(url: songUri)
        let newPlayer = AVPlayer(playerItem: playerItem)
        newPlayer.automaticallyWaitsToMinimizeStalling = true
        return newPlayer
    }

    private func prepareAVPlayer(with song: SongModel) async -> AVPlayer? {
        guard let url = await song.url else { return nil }
        return prepareAVPlayer(with: url)
    }

    private func adjacentSong(offset: Int) -> SongModel? {
        let newIndex = currentSongIndex + offset
        currentSongIndex = max(0, min(playlist.count - 1, newIndex))
        return playlist.indices.contains(newIndex) ? playlist[safe: newIndex] : nil
    }

    private func startObserving() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

        timeObserverToken = player?.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { _ in
            DispatchQueue.main.async {
                guard let duration = self.player?.currentItem?.duration.seconds, duration > 0 else { return }
                self.playbackProgress = (self.player?.currentTime().seconds ?? 0) / duration
            }
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
    }

    private func stopObserving() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }

        // swiftlint:disable notification_center_detachment

        NotificationCenter.default.removeObserver(self)

        // swiftlint:enable notification_center_detachment
    }

    @objc private func playerDidFinishPlaying() {
        if let next = adjacentSong(offset: 1) {
            play(song: next, discardPrevious: false)
        }
    }

    private func discardPlayer() {
        stopObserving()
        player = nil
        try? stopAudioSession()
    }

    private func startAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playback,
            mode: .default,
            options: [.allowAirPlay, .interruptSpokenAudioAndMixWithOthers]
        )
        try session.setActive(true)
    }

    private func stopAudioSession() throws {
        try AVAudioSession.sharedInstance().setActive(false)
    }

    private func configureRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { _ in
            self.player?.play()
            return .success
        }

        commandCenter.pauseCommand.addTarget { _ in
            self.player?.pause()
            return .success
        }

        commandCenter.togglePlayPauseCommand.addTarget { _ in
            _ = self.togglePlayPause()
            return .success
        }

        configureSkipCommand(
            commandCenter.skipForwardCommand,
            seconds: 15
        )

        configureSkipCommand(
            commandCenter.skipBackwardCommand,
            seconds: -15
        )

        commandCenter.stopCommand.addTarget { _ in
            self.stop()
            return .success
        }
    }

    private func configureSkipCommand(
        _ command: MPSkipIntervalCommand,
        seconds: Double
    ) {
        command.isEnabled = true
        command.preferredIntervals = [NSNumber(value: abs(seconds))]

        command.addTarget { _ in
            self.seek(by: seconds)
            return .success
        }
    }
}
