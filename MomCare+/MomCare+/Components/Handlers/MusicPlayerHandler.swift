import AVFoundation
import Combine
import MediaPlayer
import SwiftUI
import UIKit

@MainActor
final class MusicPlayerHandler: ObservableObject {

    // MARK: Lifecycle

    init() {
        self.configureRemoteTransportControls()
        
        if let savedPlaylistData = UserDefaults.standard.data(forKey: "loadedPlaylist"),
           let savedPlaylist = try? JSONDecoder().decode([SongModel].self, from: savedPlaylistData) {
            self.playlist = savedPlaylist
        }
        
        if let savedCurrentSongIndex = UserDefaults.standard.value(forKey: "currentSongIndex") as? Int {
            self.currentSongIndex = savedCurrentSongIndex
        }
        
        if let savedImageData = UserDefaults.standard.data(forKey: "currentSongUIImage"),
           let savedImage = UIImage(data: savedImageData) {
            self.currentSongUIImage = savedImage
        }
        
        if let song = playlist[safe: currentSongIndex] {
            Task {
                self.player = await self.prepareAVPlayer(with: song)
            }
        }
    }

    // MARK: Internal

    private(set) var player: AVPlayer?
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
    @Published var isPlaying = false
    @Published var playbackProgress: Float = 0.0
    
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
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }

        return isPlaying
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
            isPlaying = true
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
        self.currentSongIndex = newIndex
        return playlist.indices.contains(newIndex) ? playlist[safe: newIndex] : nil
    }

    private func startObserving() {
        guard let player else { return }

        let interval = CMTime(seconds: 0.02, preferredTimescale: 600)

        timeObserverToken = player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] _ in
            guard let self,
                  let duration = player.currentItem?.duration.seconds,
                  duration > 0 else { return }

            DispatchQueue.main.async {
                self.playbackProgress = Float(player.currentTime().seconds / duration)
            }
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
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
        isPlaying = false
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
            self.isPlaying = true
            return .success
        }

        commandCenter.pauseCommand.addTarget { _ in
            self.player?.pause()
            self.isPlaying = false
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
