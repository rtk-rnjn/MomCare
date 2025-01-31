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
        songLabel.text = song.name
        artistOrAlbumLabel.text = song.artist
        songImageView.image = song.image
        
        let seconds = song.duration
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        
        durationLabel.text = "\(minutes):\(remainingSeconds < 10 ? "0" : "")\(remainingSeconds)"
    }
}
