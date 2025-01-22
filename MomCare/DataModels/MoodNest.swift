// Moods.swift
// MomCare
// Created by Batch - 2 on 16/01/25.

import Foundation
import UIKit

struct Mood {
    let imageName: String
    var image: UIImage? {
        return UIImage(named: imageName)
    }
    let type: MoodType
}

struct Song {
    let name: String
    let artist: String
    let duration: TimeInterval
}

struct Playlist {
    let imageName: String
    var image: UIImage? {
        return UIImage(named: imageName)
    }
    let name: String
    let songs: [Song]
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
                Song(name: "Summe terrace", artist: "Casiio, Kainbeats", duration: 134.0),
                Song(name: "Moonrise", artist: "Trixie", duration: 132.0),
                Song(name: "Days Past", artist: "WanderLight", duration: 129.0),
                Song(name: "Rent A Movie", artist: "Kilada", duration: 129.0),
                Song(name: "Daydream", artist: "zakori", duration: 123.0),
                Song(name: "Romance", artist: "Jazza Mazza", duration: 126.0)
            ]
        ),
        Playlist(
            imageName: "I1",
            name: "Relax",
            songs: [
                Song(name: "River", artist: "ODESZA", duration: 280.0),
                Song(name: "Weightless", artist: "Marconi Union", duration: 240.0),
                Song(name: "Clair de Lune", artist: "Claude Debussy", duration: 210.0),
                Song(name: "Canon in D Major", artist: "Johann Pachelbel", duration: 180.0),
                Song(name: "Apashe - Triumph", artist: "Apashe", duration: 270.0),
                Song(name: "Summer", artist: "Calvin Harris", duration: 225.0)
            ]
        ),
        Playlist(
            imageName: "I2",
            name: "Sleep",
            songs: [
                Song(name: "Nocturne No. 2 in E Flat Major", artist: "Frédéric Chopin", duration: 180.0),
                Song(name: "Sleepyhead", artist: "Passion Pit", duration: 210.0),
                Song(name: "Arban's Carnival of Venice", artist: "Jean-Baptiste Arban", duration: 240.0),
                Song(name: "Stay Awake", artist: "Sia", duration: 200.0),
                Song(name: "The Scientist", artist: "Coldplay", duration: 270.0),
                Song(name: "All I Ask", artist: "Adele", duration: 240.0)
            ]
        ),
        Playlist(
            imageName: "I3",
            name: "Meditation",
            songs: [
                Song(name: "Enya - Only Time", artist: "Enya", duration: 240.0),
                Song(name: "Hans Zimmer - Time", artist: "Hans Zimmer", duration: 210.0),
                Song(name: "Brian Eno - An Ending (Ascent)", artist: "Brian Eno", duration: 180.0),
                Song(name: "Yiruma - River Flows In You", artist: "Yiruma", duration: 200.0),
                Song(name: "Deva Premal - Gayatri Mantra", artist: "Deva Premal", duration: 150.0),
                Song(name: "Ambient Soundscapes - Ocean Waves", artist: "Ambient Soundscapes", duration: 180.0)
            ]
        ),
        Playlist(
            imageName: "I4",
            name: "Nature Melodies",
            songs: [
                Song(name: "Bird Songs of the Amazon", artist: "Nature Sounds", duration: 240.0),
                Song(name: "Sounds of the Rainforest", artist: "Nature Sounds", duration: 300.0),
                Song(name: "Ocean Waves and Seagulls", artist: "Nature Sounds", duration: 270.0),
                Song(name: "Wind Chimes and Gentle Breeze", artist: "Nature Sounds", duration: 180.0),
                Song(name: "Cricket Chirping at Night", artist: "Nature Sounds", duration: 210.0),
                Song(name: "Forest Stream Flowing", artist: "Nature Sounds", duration: 240.0)
            ]
        ),
        Playlist(
            imageName: "I5",
            name: "Spiritual",
            songs: [
                Song(name: "Om Namah Shivaya", artist: "Various Artists", duration: 120.0),
                Song(name: "Sitar Melodies", artist: "Ravi Shankar", duration: 180.0),
                Song(name: "Gregorian Chants", artist: "Various Artists", duration: 210.0),
                Song(name: "Kirtan Music", artist: "Jai Uttal", duration: 150.0),
                Song(name: "Tibetan Singing Bowls", artist: "Various Artists", duration: 180.0),
                Song(name: "Native American Flute Music", artist: "R. Carlos Nakai", duration: 240.0)
            ]
        )
        
    ]
}
