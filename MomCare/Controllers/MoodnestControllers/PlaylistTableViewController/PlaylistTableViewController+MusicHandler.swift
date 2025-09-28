//
//  PlaylistTableViewController+MusicHandler.swift
//  MomCare
//
//  Created by RITIK RANJAN on 31/05/25.
//

import AVFoundation
import MediaPlayer
import LNPopupController

extension PlaylistTableViewController {

    @objc func playPauseButtonTapped(_ sender: Any?) {
        MusicPlayerHandler.shared.togglePlayPause { status in
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
        MusicPlayerHandler.shared.forward(by: 15)
        updatePlayPauseUI()
    }

    func backwardButtonTapped(_ sender: Any?) {
        MusicPlayerHandler.shared.backward(by: 15)
        updatePlayPauseUI()
    }

    func durationSliderValueChanged(value: Float) {
        musicPlayer.songSlider.value = value
        MusicPlayerHandler.shared.jumpToTime(CMTime(seconds: Double(value), preferredTimescale: 1), completion: nil)
    }

    func durationSliderTapped(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: musicPlayer.songSlider)
        let percentage = point.x / musicPlayer.songSlider.bounds.width
        let newValue = Float(percentage) * Float(musicPlayer.songSlider.maximumValue)
        musicPlayer.songSlider.value = newValue
        MusicPlayerHandler.shared.jumpToTime(CMTime(seconds: Double(newValue), preferredTimescale: 1), completion: nil)
    }

}
