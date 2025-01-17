//
//  Genres.swift
//  MomCare
//
//  Created by Batch - 2 on 17/01/25.
//

import Foundation
import UIKit

struct Genre {
    let name: String  // e.g., "Relaxation", "Nature Sounds"
}

struct FeaturedPlaylist {
    let image: UIImage
    let genre: Genre
}

class Playlists {
    static let FeaturedPlaylists: [FeaturedPlaylist] = [
        FeaturedPlaylist(image: UIImage(named: "I1")!, genre: Genre(name: "Relaxation")),
        FeaturedPlaylist(image: UIImage(named: "I2")!, genre: Genre(name: "Nature Sounds")),
        FeaturedPlaylist(image: UIImage(named: "I3")!, genre: Genre(name: "Music")),
        FeaturedPlaylist(image: UIImage(named: "I4")!, genre: Genre(name: "Lo-Fi")),
        FeaturedPlaylist(image: UIImage(named: "I5")!, genre: Genre(name: "Classical")),
        FeaturedPlaylist(image: UIImage(named: "I6")!, genre: Genre(name: "Spiritual"))
    ]
}

