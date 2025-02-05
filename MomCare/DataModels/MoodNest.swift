// MoodNest.swift
// MomCare
// Created by Batch - 2 on 16/01/25.

import Foundation
import UIKit

struct Mood {
    let imageName: String
    let type: MoodType

    var image: UIImage? {
        return UIImage(named: imageName)
    }

}

struct Song {
    let name: String
    let artist: String
    let duration: TimeInterval
    let imageName: String
    var isPlaying: Bool = false

    var image: UIImage? {
        return UIImage(named: imageName)
    }

}

struct Playlist {
    let imageName: String
    let name: String
    let songs: [Song]

    var image: UIImage? {
        return UIImage(named: imageName)
    }

}

class AllMoods {
    static var moods: [Mood] = [
        Mood(imageName: "Happy", type: .happy),
        Mood(imageName: "Sad", type: .sad),
        Mood(imageName: "Stressed", type: .stressed),
        Mood(imageName: "Angry", type: .angry)
    ]
}

class FeaturedPlaylists {
    static var playlists: [Playlist] = [
        Playlist(
            imageName: "I6",
            name: "Lo-fi",
            songs: [
                Song(name: "Him & I", artist: "G-Eazy, Halsey", duration: 134.0, imageName: "Him-&-I"),
                Song(name: "Unstoppable", artist: "Sia", duration: 132.0, imageName: "Unstoppable"),
                Song(name: "ABCDEFU", artist: "Gayle", duration: 129.0, imageName: "abcdefu"),
                Song(name: "Stay", artist: "The Kid LAROI, justin Bieber", duration: 129.0, imageName: "Stay"),
                Song(name: "Woman", artist: "Doja cat", duration: 123.0, imageName: "Woman"),
                Song(name: "Daechwita", artist: "august D", duration: 126.0, imageName: "Daechwita")
            ]
        ),
        Playlist(
            imageName: "I1",
            name: "Relax",
            songs: [
                Song(name: "Deep End", artist: "Foushee", duration: 280.0, imageName: "Deep-End"),
                Song(name: "Let It GO", artist: "James Bay", duration: 240.0, imageName: "Let-it-go"),
                Song(name: "You Broke Me First", artist: "conor Manyard", duration: 210.0, imageName: "You-broke-me-first"),
                Song(name: "Say Something", artist: "A Great Big World", duration: 180.0, imageName: "Say-something"),
                Song(name: "Get You The Moon", artist: "Kina, Snow", duration: 270.0, imageName: "Get-you-the-moon"),
                Song(name: "All Of Me", artist: "John Legend", duration: 225.0, imageName: "All-of-me")
            ]
        ),
        Playlist(
            imageName: "I2",
            name: "Sleep",
            songs: [
                Song(name: "Hold Up", artist: "Beyoncé", duration: 180.0, imageName: "Hold-up"),
                Song(name: "Sweetener", artist: "Ariana Grande", duration: 210.0, imageName: "Sweetener"),
                Song(name: "The Dreaming", artist: "Kate Bush", duration: 240.0, imageName: "The-dreaming"),
                Song(name: "No Agreement", artist: "Fela Kuti", duration: 200.0, imageName: "No-agreement"),
                Song(name: "First Take", artist: "Roberta Flack", duration: 270.0, imageName: "First-take"),
                Song(name: "Lonely", artist: "RM", duration: 240.0, imageName: "Lonely")
            ]
        ),
        Playlist(
            imageName: "I3",
            name: "Meditation",
            songs: [
                Song(name: "Treat You Better", artist: "Sahwn Mendes", duration: 240.0, imageName: "treat-you-better"),
                Song(name: "Time", artist: "Hans Zimmer", duration: 210.0, imageName: "time"),
                Song(name: "The Fame Monster", artist: "Lady Gaga", duration: 180.0, imageName: "The-fame-monster"),
                Song(name: "River Flows In You", artist: "Yiruma", duration: 200.0, imageName: "River-flows-in-you"),
                Song(name: "Gayatri Mantra", artist: "Deva Premal", duration: 150.0, imageName: "gayatri-mantra"),
                Song(name: "Kiss It Better", artist: "Rihanna", duration: 180.0, imageName: "Kiss-it-better")
            ]
        ),
        Playlist(
            imageName: "I4",
            name: "Nature Melodies",
            songs: [
                Song(name: "Birds in the Amazon", artist: "Nature Sounds", duration: 240.0, imageName: "Bird-in-the-amazon"),
                Song(name: "Sounds of the Rainforest", artist: "Nature Sounds", duration: 300.0, imageName: "sounds-of-the-rainforest"),
                Song(name: "Ocean Waves and Seagulls", artist: "Nature Sounds", duration: 270.0, imageName: "ocean-waves-and-seagulls"),
                Song(name: "Wind Chimes and Gentle Breeze", artist: "Nature Sounds", duration: 180.0, imageName: "wind-chimes-and-gentle-breeze"),
                Song(name: "Cricket Chirping at Night", artist: "Nature Sounds", duration: 210.0, imageName: "crickets-chirping-at-night"),
                Song(name: "Forest Stream Flowing", artist: "Nature Sounds", duration: 240.0, imageName: "forest-stream-flowing")
            ]
        ),
        Playlist(
            imageName: "I5",
            name: "Spiritual",
            songs: [
                Song(name: "Om Namah Shivaya", artist: "Various Artists", duration: 120.0, imageName: "om-namah-shivay"),
                Song(name: "Sitar Melodies", artist: "Ravi Shankar", duration: 180.0, imageName: "sitar-melodies"),
                Song(name: "Gregorian Chants", artist: "Various Artists", duration: 210.0, imageName: "gregorian-chants"),
                Song(name: "Kirtan Music", artist: "Jai Uttal", duration: 150.0, imageName: "kirtan-music"),
                Song(name: "Tibetan Singing Bowls", artist: "Various Artists", duration: 180.0, imageName: "tibetan-singing-bowls"),
                Song(name: "Native American Flute Music", artist: "R. Carlos Nakai", duration: 240.0, imageName: "native-american-flute-music")
            ]
        )

    ]
}
