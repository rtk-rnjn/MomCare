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

    func updateElements(with song: Song) {
        songLabel.text = song.name
        artistOrAlbumLabel.text = song.artist
        songImageView = UIImageView(image: UIImage(named: song.name))
    }
}
