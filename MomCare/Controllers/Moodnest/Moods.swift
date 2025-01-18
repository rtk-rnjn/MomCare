//
//  Moods.swift
//  MomCare
//
//  Created by Batch - 2  on 16/01/25.
//

import Foundation
import UIKit

struct Mood {
    let image: UIImage!
    let name: String
}

struct Playlist{
    let image: UIImage!
    let name: String
}

class AllMoods {
    static var moods: [Mood] = [
        Mood(image: UIImage(named: "Happy")!, name: "Happy"),
        Mood(image: UIImage(named: "Sad")!, name: "Sad"),
        Mood(image: UIImage(named: "Stressed")!, name: "Stressed"),
        Mood(image: UIImage(named: "Angry")!, name: "Angry")
    ]
}

class FeaturedPlaylists{
    static var playlists: [Playlist] = [
        Playlist(image: UIImage(named: "I1")!, name: "Relax"),
        Playlist(image: UIImage(named: "I2")!, name: "Sleep"),
        Playlist(image: UIImage(named: "I3")!, name: "Meditation"),
        Playlist(image: UIImage(named: "I4")!, name: "Nature Melodies"),
        Playlist(image: UIImage(named: "I5")!, name: "Spiritual"),
        Playlist(image: UIImage(named: "I6")!, name: "Lo-fi")
    ]
}
