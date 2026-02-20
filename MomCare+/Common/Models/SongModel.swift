//
//  SongModel.swift
//  MomCare+
//
//  Created by Aryan singh on 12/02/26.
//

import Foundation
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
}

struct SongMetadata: Codable, Sendable, Equatable, Hashable {
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
            guard let first = songs.first else { return nil }

            return PlaylistModel(
                mood: first.mood,
                name: playlistName,
                imageUri: songs.first(where: { $0.playlistImageUri != nil })?.playlistImageUri,
                songs: songs
            )
        }
    }

}

struct SongModel: Codable, Sendable, Identifiable, Equatable, Hashable {
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

    var image: UIImage? {
        get async {
            try? await UIImage.getOrFetch(from: songImageUri ?? "")
        }
    }

    var url: URL? {
        get async {
            guard let networkResponse = try? await ContentService.shared.fetchSongStreamUri(id: _id) else {
                return nil
            }
            if let uri = networkResponse.data?.detail {
                return URL(string: uri)
            }
            return nil
        }
    }
}
