//
//  MusicHandler.swift
//  MomCare
//
//  Created by RITIK RANJAN on 31/05/25.
//

import AVFoundation
import MediaPlayer

extension PlaylistTableViewController: MusicPlayerDelegate {
    func configureAudioSession() throws {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay, .defaultToSpeaker])
        try AVAudioSession.sharedInstance().setActive(true)
    }

    private func updateNowPlayingInfo(_ song: Song) async {
        var nowPlayingInfo: [String: Any] = [:]

        if let title = song.metadata?.title {
            nowPlayingInfo[MPMediaItemPropertyTitle] = title
        }

        if let artist = song.metadata?.artist {
            nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        }
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

        updatePlayPauseUI(setImage: imageName)

        Task.detached(priority: .background) {
            guard let song = await self.musicPlayer.song else { return }
            await self.updateNowPlayingInfo(song)
        }
    }

    func updatePlayPauseUI(setImage imageName: String = "pause.fill") {
        let config = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .largeTitle))

        musicPlayer.playButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
        initialTabBarController?.popupBar.popupItem?.barButtonItems?.first(where: { $0.action == #selector(playPauseButtonTapped) })?.image = UIImage(systemName: imageName, withConfiguration: config)

        if let viewController = songElementsViewController {
            viewController.playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
            viewController.playPauseButton.titleLabel?.text = imageName == "play.fill" ? "Play" : "Pause"
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

    func setupRemoteTransportControls() {
        commandCenter.playCommand.addTarget { _ in
            self.player?.play()
            return .success
        }

        commandCenter.pauseCommand.addTarget { _ in
            self.player?.pause()
            return .success
        }

        commandCenter.togglePlayPauseCommand.addTarget { _ in
            self.playPauseButtonTapped(nil)
            return .success
        }

        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.preferredIntervals = [15]
        commandCenter.skipForwardCommand.addTarget { _ in
            self.player?.seek(to: CMTime(seconds: (self.player?.currentTime().seconds ?? 0) + 15, preferredTimescale: 1))
            return .success
        }

        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.preferredIntervals = [15]
        commandCenter.skipBackwardCommand.addTarget { _ in
            self.player?.seek(to: CMTime(seconds: (self.player?.currentTime().seconds ?? 0) - 15, preferredTimescale: 1))
            return .success
        }
    }
}
