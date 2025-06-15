//
//  MusicHandler.swift
//  MomCare
//
//  Created by RITIK RANJAN on 31/05/25.
//

import AVFoundation
import MediaPlayer

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

    }

    func backwardButtonTapped(_ sender: Any?) {

    }

    func durationSliderValueChanged(value: Float) {

    }

    func durationSliderTapped(_ gesture: UITapGestureRecognizer) {

    }


}
