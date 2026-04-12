import Foundation
import HealthKit
import UIKit

enum MoodType: String, Codable, CaseIterable, Identifiable {
    case happy = "Happy"
    case stressed = "Stressed"
    case sad = "Sad"
    case angry = "Angry"

    // MARK: Internal

    var id: String {
        rawValue
    }

    var emoji: String {
        switch self {
        case .angry: "😡"
        case .sad: "😢"
        case .happy: "😊"
        case .stressed: "😰"
        }
    }

    var valence: Double {
        switch self {
        case .angry: -1
        case .sad: -0.5
        case .stressed: -0.25
        case .happy: 1
        }
    }

    @available(iOS 18.0, *)
    var label: HKStateOfMind.Label {
        switch self {
        case .angry: .angry
        case .sad: .sad
        case .stressed: .stressed
        case .happy: .happy
        }
    }

    static func from(int: Int) -> MoodType {
        switch int {
        case 0: .happy
        case 1: .stressed
        case 2: .sad
        case 3: .angry
        default: .happy
        }
    }
}

nonisolated struct SongMetadata: Codable, Sendable, Equatable, Hashable {
    enum CodingKeys: String, CodingKey {
        case author
        case title
        case duration
    }

    var author: String?
    var title: String?
    var duration: Double?
}

struct PlaylistModel: Identifiable {
    var id: UUID = .init()

    var mood: MoodType
    var name: String
    var imageUri: String?
    var songs: [SongModel]

    var image: UIImage? {
        get async {
            try? await UIImage.getOrFetch(from: imageUri ?? "")
        }
    }

    static func from(allSongs: [SongModel]) -> [PlaylistModel] {
        let grouped = Dictionary(grouping: allSongs) { $0.playlist }

        return grouped.compactMap { playlistName, songs in
            guard let first = songs.first else {
                return nil
            }

            return PlaylistModel(
                mood: first.mood,
                name: playlistName,
                imageUri: songs.first(where: { $0.playlistImageUri != nil })?.playlistImageUri,
                songs: songs
            )
        }
    }
}

nonisolated struct SongModel: Codable, Sendable, Identifiable, Equatable, Hashable {
    enum CodingKeys: String, CodingKey {
        case _id
        case mood
        case playlist
        case songName = "song_name"
        case imageName = "image_name"
        case metadata
        case playlistImageUri = "playlist_image_uri"
        case songImageUri = "song_image_uri"
    }

    var _id: String
    var mood: MoodType
    var playlist: String
    var songName: String
    var imageName: String
    var metadata: SongMetadata?

    var playlistImageUri: String?
    var songImageUri: String?

    var id: String {
        _id
    }

    var title: String {
        metadata?.title ?? songName
    }

    var image: UIImage? {
        get async {
            try? await UIImage.getOrFetch(from: songImageUri ?? "")
        }
    }
}
