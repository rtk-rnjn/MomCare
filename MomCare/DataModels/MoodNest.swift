// MoodNest.swift
// MomCare
// Created by Batch - 2 on 16/01/25.

import Foundation
import UIKit

struct Song: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case artist
        case duration
        case imageUri = "image_uri"
        case uri
    }

    var name: String
    var artist: String
    var duration: TimeInterval
    var imageUri: String?

    var uri: String?

    var url: URL? {
        guard let uri else { return nil }
        return URL(string: uri)
    }

    var image: UIImage? {
        guard let imageUri else { return UIImage(named: "music.note") }
        return UIImage(named: imageUri) ?? UIImage(named: "music.note")
    }

}

struct Playlist: Codable, Sendable {
    var id: UUID = .init()

    var imageName: String
    var name: String
    var songs: [Song]

    var forMood: MoodType? = .happy

    var image: UIImage? {
        return UIImage(named: imageName)
    }
}

enum SampleFeaturedPlaylists {
    public static let playlists: [Playlist] = [
        Playlist(
            imageName: "Lofi",
            name: "Lo-fi",
            songs: [
                Song(name: "Him & I", artist: "G-Eazy, Halsey", duration: 134.0, imageUri: "Him-&-I"),
                Song(name: "Unstoppable", artist: "Sia", duration: 132.0, imageUri: "Unstoppable"),
                Song(name: "ABCDEFU", artist: "Gayle", duration: 129.0, imageUri: "abcdefu"),
                Song(name: "Stay", artist: "The Kid LAROI, justin Bieber", duration: 129.0, imageUri: "Stay-Image"),
                Song(name: "Woman", artist: "Doja cat", duration: 123.0, imageUri: "Woman"),
                Song(name: "Daechwita", artist: "august D", duration: 126.0, imageUri: "Daechwita")
            ]
        ),
        Playlist(
            imageName: "Relax",
            name: "Relax",
            songs: [
                Song(name: "Deep End", artist: "Foushee", duration: 280.0, imageUri: "Deep-End"),
                Song(name: "Let It GO", artist: "James Bay", duration: 240.0, imageUri: "Let-it-go"),
                Song(name: "You Broke Me First", artist: "conor Manyard", duration: 210.0, imageUri: "You-broke-me-first"),
                Song(name: "Say Something", artist: "A Great Big World", duration: 180.0, imageUri: "Say-something"),
                Song(name: "Get You The Moon", artist: "Kina, Snow", duration: 270.0, imageUri: "Get-you-the-moon"),
                Song(name: "All Of Me", artist: "John Legend", duration: 225.0, imageUri: "All-of-me")
            ]
        ),
        Playlist(
            imageName: "Sleep",
            name: "Sleep",
            songs: [
                Song(name: "Hold Up", artist: "Beyoncé", duration: 180.0, imageUri: "Hold-up"),
                Song(name: "Sweetener", artist: "Ariana Grande", duration: 210.0, imageUri: "Sweetener"),
                Song(name: "The Dreaming", artist: "Kate Bush", duration: 240.0, imageUri: "The-dreaming"),
                Song(name: "No Agreement", artist: "Fela Kuti", duration: 200.0, imageUri: "No-agreement"),
                Song(name: "First Take", artist: "Roberta Flack", duration: 270.0, imageUri: "First-take"),
                Song(name: "Lonely", artist: "RM", duration: 240.0, imageUri: "Lonely")
            ]
        ),
        Playlist(
            imageName: "Meditation",
            name: "Meditation",
            songs: [
                Song(name: "Treat You Better", artist: "Sahwn Mendes", duration: 240.0, imageUri: "treat-you-better"),
                Song(name: "Time", artist: "Hans Zimmer", duration: 210.0, imageUri: "time"),
                Song(name: "The Fame Monster", artist: "Lady Gaga", duration: 180.0, imageUri: "The-fame-monster"),
                Song(name: "River Flows In You", artist: "Yiruma", duration: 200.0, imageUri: "River-flows-in-you"),
                Song(name: "Gayatri Mantra", artist: "Deva Premal", duration: 150.0, imageUri: "gayatri-mantra"),
                Song(name: "Kiss It Better", artist: "Rihanna", duration: 180.0, imageUri: "Kiss-it-better")
            ]
        ),
        Playlist(
            imageName: "Nature Melodies",
            name: "Nature Melodies",
            songs: [
                Song(name: "Birds in the Amazon", artist: "Nature Sounds", duration: 240.0, imageUri: "Bird-in-the-amazon"),
                Song(name: "Sounds of the Rainforest", artist: "Nature Sounds", duration: 300.0, imageUri: "sounds-of-the-rainforest"),
                Song(name: "Ocean Waves and Seagulls", artist: "Nature Sounds", duration: 270.0, imageUri: "ocean-waves-and-seagulls"),
                Song(name: "Wind Chimes and Gentle Breeze", artist: "Nature Sounds", duration: 180.0, imageUri: "wind-chimes-and-gentle-breeze"),
                Song(name: "Cricket Chirping at Night", artist: "Nature Sounds", duration: 210.0, imageUri: "crickets-chirping-at-night"),
                Song(name: "Forest Stream Flowing", artist: "Nature Sounds", duration: 240.0, imageUri: "forest-stream-flowing")
            ]
        ),
        Playlist(
            imageName: "Spiritual",
            name: "Spiritual",
            songs: [
                Song(name: "Om Namah Shivaya", artist: "Various Artists", duration: 120.0, imageUri: "om-namah-shivay"),
                Song(name: "Sitar Melodies", artist: "Ravi Shankar", duration: 180.0, imageUri: "sitar-melodies"),
                Song(name: "Gregorian Chants", artist: "Various Artists", duration: 210.0, imageUri: "gregorian-chants"),
                Song(name: "Kirtan Music", artist: "Jai Uttal", duration: 150.0, imageUri: "kirtan-music"),
                Song(name: "Tibetan Singing Bowls", artist: "Various Artists", duration: 180.0, imageUri: "tibetan-singing-bowls"),
                Song(name: "Native American Flute Music", artist: "R. Carlos Nakai", duration: 240.0, imageUri: "native-american-flute-music")
            ]
        )
    ]
}

let mp3Songs = ["Treat You Better", "Stay", "Sweetner"]
