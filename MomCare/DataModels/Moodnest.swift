import Foundation
import UIKit

/// Represents metadata of a song such as title, artist, and duration.
struct SongMetadata: Codable, Sendable, Equatable {

    /// Keys used for encoding/decoding.
    enum CodingKeys: String, CodingKey {
        case title
        case artist
        case duration
    }

    /// The title of the song.
    let title: String?

    /// The artist of the song.
    let artist: String?

    /// Duration of the song in seconds.
    let duration: TimeInterval
}

/// Represents a song with associated metadata and image.
struct Song: Codable, Sendable, Equatable {

    /// Keys used for encoding/decoding.
    enum CodingKeys: String, CodingKey {
        case imageUri = "image_uri"
        case metadata
        case uri
    }

    /// Metadata of the song (title, artist, duration).
    var metadata: SongMetadata?

    /// URI of the song's artwork image.
    var imageUri: String?

    /// URI of the audio file (string format).
    var uri: String

    /// Computed property to convert the `uri` string into a URL.
    var url: URL? {
        return URL(string: uri)
    }

    /// Asynchronously fetches the song's artwork as a UIImage.
    /// If fetching fails, returns a default system image.
    var image: UIImage? {
        get async {
            let defaultImage = UIImage(systemName: "music.note")
            return await UIImage().fetchImage(from: imageUri, default: defaultImage)
        }
    }
}
