//
//  SongPageTableViewCell.swift
//  MomCare
//
//  Created by Batch - 2  on 20/01/25.
//

import UIKit

class SongPageTableViewCell: UITableViewCell {
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistOrAlbumLabel: UILabel!
    @IBOutlet weak var songImageView: UIImageView!
    
    func updateElement(with song: Song) {
        songLabel.text = song.name
        artistOrAlbumLabel.text = song.artist
        songImageView = UIImageView(image: UIImage(named: song.name))
    }
}
