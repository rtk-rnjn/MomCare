//
//  PlayerViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 29/01/25.
//

import UIKit
import CoreImage
import AVFoundation
import AVKit

class PlayerViewController: UIViewController {

    var audioPlayer: AVAudioPlayer!
    var currentSongIndex: Int = 0
    
    // MARK: - OUTLETS
    @IBOutlet var playerImageView: UIImageView!
    @IBOutlet var songTitleLabel: UILabel!
    @IBOutlet var songArtistLabel: UILabel!
    @IBOutlet var songDurationLabel: UILabel!
    @IBOutlet var audioSlider: UISlider!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var repeatButton: UIButton!
    
    var song: Song?
    let gradientLayer: CAGradientLayer = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareSelectedSong()
        loadCurrentSong()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
        playPauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
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

    // MARK: Private

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
    
    // MARK: AVPLAYER SECTION
    func loadCurrentSong() {
        guard let audioData = NSDataAsset(name: mp3Songs[currentSongIndex])?.data else {
            print("Audio file not found: \(mp3Songs[currentSongIndex])")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print("Error initializing player: \(error.localizedDescription)")
        }
        
        setupSlider()
    }
    
    @IBAction func playPauseTapped(_ sender: UIButton) {
        if audioPlayer.isPlaying {
            audioPlayer.pause()
            sender.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        } else {
            audioPlayer.play()
            sender.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        }
    }
    
    @IBAction func forwardTapped(_ sender: UIButton) {
        currentSongIndex = (currentSongIndex + 1) % mp3Songs.count
        loadCurrentSong()
        updateView()
    }
    
    @IBAction func backwardTapped(_ sender: UIButton) {
        currentSongIndex = (currentSongIndex - 1 + mp3Songs.count) % mp3Songs.count
        loadCurrentSong()
        updateView()
    }
    
    @IBAction func repeatTapped(_ sender: UIButton) {
        audioPlayer.numberOfLoops = audioPlayer.numberOfLoops == 0 ? -1 : 0
        let imageName = audioPlayer.numberOfLoops == -1 ? "repeat.circle.fill" : "repeat.circle"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    func setupSlider() {
        audioSlider.minimumValue = 0
        audioSlider.maximumValue = Float(audioPlayer.duration)
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.audioSlider.value = Float(self.audioPlayer.currentTime)
        }
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        audioPlayer.currentTime = TimeInterval(sender.value)
    }

}
