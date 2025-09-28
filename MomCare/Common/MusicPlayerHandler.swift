//
//  MusicPlayerHandler.swift
//  MomCare
//
//  Created by RITIK RANJAN on 15/06/25.
//

import UIKit
import MediaPlayer
@preconcurrency import AVFoundation

class MusicPlayerHandler {

    // MARK: Lifecycle

    private init() {
        configureRemoteTransportControls()
    }

    // MARK: Public

    public private(set) var player: AVPlayer?
    public private(set) var currentSong: Song?

    // MARK: Internal

    nonisolated(unsafe) static let shared: MusicPlayerHandler = .init()

    var interfaceUpdater: ((AVPlayer.TimeControlStatus?) -> Void)?

    var timeObserverToken: Any?
    var periodicUpdater: ((CMTime) -> Void)?
    var songFinishedCompletionHandler: (() -> Void)?

    func preparePlayer(song: Song, periodicUpdater: @escaping (CMTime) -> Void, songFinishedCompletionHandler: @escaping () -> Void, completion: @Sendable @escaping () -> Void) {
        discardPlayer()

        try? startAudioSession()

        guard let url = song.url else {
            return
        }
        player = AVPlayer(url: url)
        self.periodicUpdater = periodicUpdater
        self.songFinishedCompletionHandler = songFinishedCompletionHandler
        currentSong = song

        player?.automaticallyWaitsToMinimizeStalling = false
        startObserving(player)

        completion()
    }

    func stop() {
        player?.pause()
        discardPlayer()
    }

    func togglePlayPause(completion: (@Sendable (AVPlayer.TimeControlStatus?) -> Void)?) {

        if player?.timeControlStatus == .playing {
            player?.pause()
        } else {
            player?.play()
        }

        completion?(player?.timeControlStatus)

        guard let song = currentSong else {
            return
        }
        Task.detached(priority: .background) {
            await MusicPlayerHandler.shared.updateNowPlayingInfo(song)
        }
    }

    func forward(by seconds: Double) {
        guard let currentTime = player?.currentTime() else { return }
        let newTime = CMTime(seconds: currentTime.seconds + seconds, preferredTimescale: 1)
        player?.seek(to: newTime)
    }

    func backward(by seconds: Double) {
        guard let currentTime = player?.currentTime() else { return }
        let newTime = CMTime(seconds: currentTime.seconds - seconds, preferredTimescale: 1)
        player?.seek(to: newTime)
    }

    func jumpToTime(_ timePercent: CMTime, completion: (() -> Void)?) {
        guard let player else { return }
        let duration = player.currentItem?.duration ?? .zero
        let newTime = CMTime(seconds: timePercent.seconds * duration.seconds, preferredTimescale: 1)
        player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
        player.play()

        completion?()
        guard let song = currentSong else {
            return
        }
        Task.detached(priority: .background) {
            await MusicPlayerHandler.shared.updateNowPlayingInfo(song)
        }
    }

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

    private func discardPlayer() {
        stopObserving()
        player = nil
        currentSong = nil
        periodicUpdater = nil

        try? stopAudioSession()
    }

    private func startObserving(_ player: AVPlayer?) {
        guard let player else { return }
        let interval = CMTime(seconds: 0.02, preferredTimescale: 600)
        let song = currentSong
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            DispatchQueue.main.async {
                MusicPlayerHandler.shared.periodicUpdater?(time)
            }
            guard let song else {
                return
            }
            Task.detached(priority: .background) {

                await MusicPlayerHandler.shared.updateNowPlayingInfo(song)
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }

    private func stopObserving() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
        player = nil
        currentSong = nil
    }

    @objc private func playerDidFinishPlaying(_ notification: Notification) {
        guard let item = notification.object as? AVPlayerItem else { return }
        if item == player?.currentItem {
            discardPlayer()
        }
        songFinishedCompletionHandler?()
    }

    private func startAudioSession() throws {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay, .defaultToSpeaker, .interruptSpokenAudioAndMixWithOthers])
        try AVAudioSession.sharedInstance().setActive(true)
    }

    private func stopAudioSession() throws {
        try AVAudioSession.sharedInstance().setActive(false)
    }

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

        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.preferredIntervals = [15]
        commandCenter.skipForwardCommand.addTarget { _ in
            self.player?.seek(to: CMTime(seconds: (self.player?.currentTime().seconds ?? 0) + 15, preferredTimescale: 1))

            self.interfaceUpdater?(self.player?.timeControlStatus)

            return .success
        }

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
