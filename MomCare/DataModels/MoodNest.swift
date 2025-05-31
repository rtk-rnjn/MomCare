// MoodNest.swift
// MomCare
// Created by Batch - 2 on 16/01/25.

import Foundation
import UIKit
@preconcurrency import AVFoundation

struct SongMetadata: Codable, Sendable, Equatable {
    enum CodingKeys: String, CodingKey {
        case title
        case artist
        case duration
    }

    let title: String?
    let artist: String?
    let duration: TimeInterval
}

struct Song: Codable, Sendable, Equatable {
    enum CodingKeys: String, CodingKey {
        case imageUri = "image_uri"
        case metadata
        case uri
    }

    var metadata: SongMetadata?
    var imageUri: String?
    var uri: String

    var url: URL? {
        return URL(string: uri)
    }

    var image: UIImage? {
        get async {
            let defaultImage = UIImage(systemName: "music.note")
            return await UIImage().fetchImage(from: imageUri, default: defaultImage)
        }
    }

    var asset: AVAsset? {
        get async {
            guard let url else { return nil }
            return await AVAsset(url: url)
        }
    }

}
