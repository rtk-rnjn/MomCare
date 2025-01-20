// Moods.swift
// MomCare
// Created by Batch - 2 on 16/01/25.

import Foundation
import UIKit

struct Mood {

    let image: UIImage!
    let name: String
}

struct Song {
    let name: String
    let artist: String
    let duration: TimeInterval // You can use TimeInterval for duration
}

struct Playlist {
    let image: UIImage!
    let name: String
    let songs: [Song]
}

class AllMoods {
    static var moods: [Mood] = [
        Mood(image: UIImage(named: "Happy")!, name: "Happy"),
        Mood(image: UIImage(named: "Sad")!, name: "Sad"),
        Mood(image: UIImage(named: "Stressed")!, name: "Stressed"),
        Mood(image: UIImage(named: "Angry")!, name: "Angry")
    ]
}

class FeaturedPlaylists {
    static var playlists: [Playlist] = [
        Playlist(
            image: UIImage(named: "I1")!,
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
            image: UIImage(named: "I2")!,
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
            image: UIImage(named: "I3")!,
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
            image: UIImage(named: "I4")!,
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
            image: UIImage(named: "I5")!,
            name: "Spiritual",
            songs: [
                Song(name: "Om Namah Shivaya", artist: "Various Artists", duration: 120.0),
                Song(name: "Sitar Melodies", artist: "Ravi Shankar", duration: 180.0),
                Song(name: "Gregorian Chants", artist: "Various Artists", duration: 210.0),
                Song(name: "Kirtan Music", artist: "Jai Uttal", duration: 150.0),
                Song(name: "Tibetan Singing Bowls", artist: "Various Artists", duration: 180.0),
                Song(name: "Native American Flute Music", artist: "R. Carlos Nakai", duration: 240.0)
            ]
        ),
        Playlist(
            image: UIImage(named: "I6")!,
            name: "Lo-fi",
            songs: [
                Song(name: "Summertime", artist: "J Dilla", duration: 180.0),
                Song(name: "Arabesque", artist: "Nujabes", duration: 210.0),
                Song(name: "Re: Stacks", artist: "Madlib", duration: 195.0),
                Song(name: "Midnight", artist: "Mac Miller", duration: 240.0),
                Song(name: "Reflection Eternal", artist: "DJ Shadow", duration: 270.0),
                Song(name: "Distant Lights", artist: "Bonobo", duration: 225.0)
            ]
        )
    ]
}
