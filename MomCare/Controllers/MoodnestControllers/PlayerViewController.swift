//
//  PlayerViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 29/01/25.
//

import UIKit
import CoreImage

class PlayerViewController: UIViewController {
    // MARK: - OUTLETS
    @IBOutlet var playerImageView: UIImageView!
    @IBOutlet var songTitleLabel: UILabel!
    @IBOutlet var songArtistLabel: UILabel!
    @IBOutlet var songDurationLabel: UILabel!

    var song: Song?
    let gradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareSelectedSong()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }

    private func prepareSelectedSong() {
        let navController = navigationController as? SongPagePlayerNavigationController
        guard let navController else { return }
        song = navController.selectedSong
    }

    private func updateView() {
        updateUIForNewSong(songImage: song?.image)
        playerImageView.image = song?.image
        songTitleLabel.text = song?.name
        songArtistLabel.text = song?.artist

        let seconds = Int(song?.duration ?? 0)
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        let durationString = String(format: "%02d:%02d", minutes, remainingSeconds)
        songDurationLabel.text = durationString
    }

    func updateGradientBackground(with color: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds

        let lighterColor = color.withAlphaComponent(0.8).cgColor
        let middleColor = color.withAlphaComponent(1.0).cgColor
        let darkerColor = UIColor.black.withAlphaComponent(0.9).cgColor

        gradientLayer.colors = [lighterColor, middleColor, darkerColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    func updateUIForNewSong(songImage: UIImage?) {
        guard let songImage else { return }
        if let dominantColor = songImage.dominantColor() {
            updateGradientBackground(with: dominantColor)
        }
    }
}
