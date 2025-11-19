//
//  SongPageTableViewCell.swift
//  MomCare
//
//  Created by Batch - 2  on 20/01/25.
//

import UIKit

class SongPageTableViewCell: UITableViewCell {
    @IBOutlet var songLabel: UILabel!
    @IBOutlet var artistOrAlbumLabel: UILabel!
    @IBOutlet var songImageView: UIImageView!
    @IBOutlet var durationLabel: UILabel!

    func updateElements(with song: Song) {
        songLabel.text = song.title
        songLabel.accessibilityLabel = "Tune name: \(songLabel.text ?? "Unknown")"
        artistOrAlbumLabel.text = song.artist
        artistOrAlbumLabel.accessibilityLabel = "Composure name: \(artistOrAlbumLabel.text ?? "Unknown")"
        Task {
            songImageView.image = await song.image
            songImageView.accessibilityLabel = "Album Artwork for \(songLabel.text ?? "Unknown")"
            songImageView.accessibilityHint = "Represent the cover image for the current song"
        }

        let seconds = song.duration ?? 0.0
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60

        if seconds == 0 {
            durationLabel.text = "--:--"
        } else {
            durationLabel.text = "\(minutes):\(remainingSeconds < 10 ? "0" : "")\(remainingSeconds)"

        }
        durationLabel.accessibilityLabel = "Tune Duration: \(durationLabel.text ?? "Unknown"))"
    }
}
