//
//  MusicPlayerHandler.swift
//  MomCare
//
//  Created by RITIK RANJAN on 15/06/25.
//

import UIKit
import MediaPlayer
@preconcurrency import AVFoundation

/// Singleton class responsible for managing music playback in the app.
///
/// Handles:
/// - Playback via `AVPlayer`
/// - Periodic updates for UI (e.g., progress bars)
/// - Forward/backward seeking
/// - Integration with Now Playing Info Center for lock screen and control center
/// - Remote transport controls (play/pause/skip)
class MusicPlayerHandler {

    // MARK: Lifecycle

    /// Private initializer to enforce singleton pattern.
    private init() {
        configureRemoteTransportControls()
    }

    // MARK: Public

    /// The active `AVPlayer` instance used for playback.
    public private(set) var player: AVPlayer?

    /// Currently playing song.
    public private(set) var currentSong: Song?

    // MARK: Internal

    /// Shared singleton instance of the `MusicPlayerHandler`.
    nonisolated(unsafe) static let shared: MusicPlayerHandler = .init()

    /// Closure to update the UI based on player's time control status (playing/paused).
    var interfaceUpdater: ((AVPlayer.TimeControlStatus?) -> Void)?

    /// Time observer token for AVPlayer periodic updates.
    var timeObserverToken: Any?

    /// Closure called periodically during playback (e.g., to update progress bars).
    var periodicUpdater: ((CMTime) -> Void)?

    /// Closure called when the current song finishes playing.
    var songFinishedCompletionHandler: (() -> Void)?

    /// Prepares the player with a given song and sets up periodic and completion callbacks.
    ///
    /// - Parameters:
    ///   - song: The `Song` object to play.
    ///   - periodicUpdater: Closure called periodically with current playback time.
    ///   - songFinishedCompletionHandler: Closure called when song finishes.
    ///   - completion: Completion handler called after player is ready.
    func preparePlayer(
        song: Song,
        periodicUpdater: @escaping (CMTime) -> Void,
        songFinishedCompletionHandler: @escaping () -> Void,
        completion: @Sendable @escaping () -> Void
    ) {
        discardPlayer()
        try? startAudioSession()

        guard let url = song.url else { return }
        player = AVPlayer(url: url)
        self.periodicUpdater = periodicUpdater
        self.songFinishedCompletionHandler = songFinishedCompletionHandler
        currentSong = song

        player?.automaticallyWaitsToMinimizeStalling = false
        startObserving(player)

        completion()
    }

    /// Stops playback and discards the current player.
    func stop() {
        player?.pause()
        discardPlayer()
    }

    /// Toggles play/pause state of the current player.
    ///
    /// - Parameter completion: Optional closure with current `TimeControlStatus`.
    func togglePlayPause(completion: (@Sendable (AVPlayer.TimeControlStatus?) -> Void)?) {
        if player?.timeControlStatus == .playing {
            player?.pause()
        } else {
            player?.play()
        }

        completion?(player?.timeControlStatus)

        guard let song = currentSong else { return }
        Task.detached(priority: .background) {
            await MusicPlayerHandler.shared.updateNowPlayingInfo(song)
        }
    }

    /// Skips forward by a given number of seconds.
    func forward(by seconds: Double) {
        guard let currentTime = player?.currentTime() else { return }
        let newTime = CMTime(seconds: currentTime.seconds + seconds, preferredTimescale: 1)
        player?.seek(to: newTime)
    }

    /// Skips backward by a given number of seconds.
    func backward(by seconds: Double) {
        guard let currentTime = player?.currentTime() else { return }
        let newTime = CMTime(seconds: currentTime.seconds - seconds, preferredTimescale: 1)
        player?.seek(to: newTime)
    }

    /// Jumps to a specific time (percentage of total duration) in the current song.
    func jumpToTime(_ timePercent: CMTime, completion: (() -> Void)?) {
        guard let player else { return }
        let duration = player.currentItem?.duration ?? .zero
        let newTime = CMTime(seconds: timePercent.seconds * duration.seconds, preferredTimescale: 1)
        player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
        player.play()

        completion?()

        guard let song = currentSong else { return }
        Task.detached(priority: .background) {
            await MusicPlayerHandler.shared.updateNowPlayingInfo(song)
        }
    }

    /// Updates the Now Playing Info Center with metadata for the current song.
    ///
    /// - Parameter song: The `Song` object containing metadata and artwork.
    func updateNowPlayingInfo(_ song: Song) async {
        var nowPlayingInfo: [String: Any] = [:]

        if let title = song.metadata?.title {
            nowPlayingInfo[MPMediaItemPropertyTitle] = title
        }
        if let artist = song.metadata?.artist {
            nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        }

        let image = await song.image
        if let image {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }

        if let elapsedTime = player?.currentTime().seconds {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        }

        if let durationTime = try? await player?.currentItem?.asset.load(.duration), durationTime.isNumeric {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = durationTime.seconds
        }

        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0

        await MainActor.run {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }

    // MARK: Private

    /// Discards the current player and stops observing its events.
    private func discardPlayer() {
        stopObserving()
        player = nil
        currentSong = nil
        periodicUpdater = nil
        try? stopAudioSession()
    }

    /// Starts periodic observation of the player for UI updates and Now Playing Info updates.
    private func startObserving(_ player: AVPlayer?) {
        guard let player else { return }
        let interval = CMTime(seconds: 0.02, preferredTimescale: 600)
        let song = currentSong
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            DispatchQueue.main.async {
                MusicPlayerHandler.shared.periodicUpdater?(time)
            }
            guard let song else { return }
            Task.detached(priority: .background) {
                await MusicPlayerHandler.shared.updateNowPlayingInfo(song)
            }
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying(_:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
    }

    /// Stops observing player events and removes periodic time observer.
    private func stopObserving() {
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
        player = nil
        currentSong = nil
    }

    /// Called when a song finishes playing.
    @objc private func playerDidFinishPlaying(_ notification: Notification) {
        guard let item = notification.object as? AVPlayerItem else { return }
        if item == player?.currentItem { discardPlayer() }
        songFinishedCompletionHandler?()
    }

    /// Configures the audio session for playback.
    private func startAudioSession() throws {
        try AVAudioSession.sharedInstance().setCategory(
            .playback,
            mode: .default,
            options: [.allowAirPlay, .defaultToSpeaker, .interruptSpokenAudioAndMixWithOthers]
        )
        try AVAudioSession.sharedInstance().setActive(true)
    }

    /// Stops the audio session.
    private func stopAudioSession() throws {
        try AVAudioSession.sharedInstance().setActive(false)
    }

    /// Configures remote transport controls (play/pause/skip) for Control Center and lock screen.
    private func configureRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { _ in
            self.player?.play()
            self.interfaceUpdater?(self.player?.timeControlStatus)
            return .success
        }

        commandCenter.pauseCommand.addTarget { _ in
            self.player?.pause()
            self.interfaceUpdater?(self.player?.timeControlStatus)
            return .success
        }

        commandCenter.togglePlayPauseCommand.addTarget { _ in
            self.togglePlayPause(completion: nil)
            self.interfaceUpdater?(self.player?.timeControlStatus)
            return .success
        }

        // Skip forward 15 seconds
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.preferredIntervals = [15]
        commandCenter.skipForwardCommand.addTarget { _ in
            self.player?.seek(to: CMTime(seconds: (self.player?.currentTime().seconds ?? 0) + 15, preferredTimescale: 1))
            self.interfaceUpdater?(self.player?.timeControlStatus)
            return .success
        }

        // Skip backward 15 seconds
        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.preferredIntervals = [15]
        commandCenter.skipBackwardCommand.addTarget { _ in
            self.player?.seek(to: CMTime(seconds: (self.player?.currentTime().seconds ?? 0) - 15, preferredTimescale: 1))
            self.interfaceUpdater?(self.player?.timeControlStatus)
            return .success
        }

        commandCenter.stopCommand.addTarget { _ in
            self.stop()
            self.interfaceUpdater?(self.player?.timeControlStatus)
            return .success
        }
    }
}
