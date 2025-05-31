//
//  ContentHandler.swift
//  MomCare
//
//  Created by RITIK RANJAN on 05/03/25.
//

import Foundation
import AVFoundation

struct Tip: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case todaysFocus = "todays_focus"
        case dailyTip = "daily_tip"
    }

    var todaysFocus: String
    var dailyTip: String

}

struct FoodSearchQuery: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case foodName = "food_name"
        case limit
    }

    var foodName: String
    var limit: Int = 10
}

struct S3Response: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case uri = "link"
        case expiryAt = "link_expiry_at"
    }

    var uri: String
    var expiryAt: Date?
}

@MainActor
class ContentHandler {

    // MARK: Public

    static var shared: ContentHandler = .init()

    // MARK: Internal

    var plan: MyPlan? {
        set {
            CacheHandler.shared.set(newValue, forKey: "plan")
        }
        get {
            return CacheHandler.shared.get(forKey: "plan")
        }
    }

    var tips: Tip? {
        set {
            CacheHandler.shared.set(newValue, forKey: "tips")
        }
        get {
            return CacheHandler.shared.get(forKey: "tips")
        }
    }

    @discardableResult
    func fetchPlan(from userMedical: UserMedical) async -> MyPlan {
        if let plan {
            return plan
        }

        let plan: MyPlan? = await NetworkManager.shared.get(url: "/content/plan")
        guard let plan else {
            return MyPlan()
        }

        self.plan = plan
        return plan
    }

    @discardableResult
    func fetchTips(from user: User) async -> Tip {
        if let tips {
            return tips
        }

        let tips: Tip? = await NetworkManager.shared.get(url: "/content/tips")
        guard let tips else {
            return Tip(todaysFocus: "Unable to fetch Today's Focus from the server", dailyTip: "Unable to fetch Daily Tip from the server")
        }

        self.tips = tips
        return tips
    }

    func searchStreamedFood(with query: String, onItem: (@Sendable (FoodItem) -> Void)?) async {
        let searchQeury = FoodSearchQuery(foodName: query)
        let sendableQeury: [String: Any]? = searchQeury.toDictionary(snakeCase: true)

        await NetworkManager.shared.fetchStreamedData(.GET, url: "/content/search", queryParameters: sendableQeury, onItem: onItem)
    }

    func fetchExercise() async -> [Exercise]? {
        return [
            .init(name: "Name1", duration: 100, description: "Description1", exerciseImageUri: ""),
            .init(name: "Name2", duration: 100, description: "Description2", exerciseImageUri: ""),
            .init(name: "Name3", duration: 100, description: "Description3", exerciseImageUri: "")
        ]
    }

    // MARK: Private

    private func fetchFromUserDefaults() -> Tip? {
        guard let data = UserDefaults.standard.data(forKey: "tips") else { return nil }

        return try? JSONDecoder().decode(Tip.self, from: data)
    }

    private func saveToUserDefaults(_ tips: Tip) {
        guard let data = tips.toData() else {
            return
        }
        UserDefaults.standard.set(data, forKey: "tips")
    }
}

extension ContentHandler {
    func fetchS3File(_ path: String) async -> S3Response? {
        await NetworkManager.shared.get(url: "/content/s3/file/\(path)")
    }

    func fetchS3Files(_ path: String) async -> [String]? {
        await NetworkManager.shared.get(url: "/content/s3/files/\(path)")
    }

    func fetchS3Directories(_ path: String) async -> [String]? {
        await NetworkManager.shared.get(url: "/content/s3/directories/\(path)")
    }
}

extension ContentHandler {
    func fetchPlaylists(forMood: MoodType) async -> [(imageUri: String, label: String)]? {
        let directories = await getMoodDirectories(forMood)
        guard !directories.isEmpty else { return nil }

        return await buildPlaylistData(from: directories)
    }

    private func getMoodDirectories(_ mood: MoodType) async -> [String] {
        let moodValue = mood.rawValue
        return await fetchS3Directories("Songs/\(moodValue)/") ?? []
    }

    private func buildPlaylistData(from directories: [String]) async -> [(imageUri: String, label: String)] {
        var result: [(imageUri: String, label: String)] = []

        for directory in directories where !directory.isEmpty {
            let uri = "\(directory)cover.jpg"
            let label = extractLastPathComponent(from: directory)

            if let response = await fetchS3File(uri) {
                result.append((imageUri: response.uri, label: label))
            }
        }

        return result
    }

    private func extractLastPathComponent(from path: String) -> String {
        path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            .components(separatedBy: "/")
            .last ?? ""
    }

    func fetchPlaylistSongs(forMood: MoodType, playlistName: String) async -> [Song]? {
        let (songsPath, imagePath) = getPaths(forMood: forMood, playlistName: playlistName)

        let paths = await fetchS3Files(songsPath) ?? []
        let images = await fetchS3Files(imagePath) ?? []
        let imageNames = extractFilenames(from: images)

        return await matchSongsToImages(songsPath: paths, imageNames: imageNames, imagePath: imagePath)
    }

    private func getPaths(forMood: MoodType, playlistName: String) -> (String, String) {
        let base = "Songs/\(forMood.rawValue)/\(playlistName)"
        return ("\(base)/Song/", "\(base)/Image/")
    }

    private func extractFilenames(from paths: [String]) -> [String] {
        paths.map { path in
            let components = path.split(separator: "/")
            return String(components.last ?? "")
        }
    }

    private func matchSongsToImages(songsPath: [String], imageNames: [String], imagePath: String) async -> [Song] {
        var result: [Song] = []

        for songPath in songsPath {
            guard let imageFile = findMatchingImage(for: songPath, from: imageNames) else { continue }

            let fullImagePath = "\(imagePath)\(imageFile)"
            let actualImageUri = await fetchS3File(fullImagePath)?.uri

            guard var songObject: Song = await NetworkManager.shared.get(url: "/content/s3/song/\(songPath)"),
                  let actualImageUri else {
                continue
            }
            songObject.imageUri = actualImageUri
//            let _ = await downloadSong(from: songObject.uri)  // TODO: Handle the downloaded song URL if needed
            result.append(songObject)
        }

        return result
    }

    private func findMatchingImage(for song: String, from imageNames: [String]) -> String? {
        let songKey = song.lowercased().replacingOccurrences(of: " ", with: "")
        return imageNames.first { image in
            let name = image.split(separator: ".").first?
                .replacingOccurrences(of: " ", with: "")
                .lowercased()
            return name.map { songKey.contains($0) } ?? false
        }
    }

    func downloadSong(from uri: String) async -> URL? {
        do {
            return try await downloadAndStoreSong(from: uri)
        } catch {
            return nil
        }
    }

    private func downloadAndStoreSong(from uri: String) async throws -> URL {
        guard let url = URL(string: uri) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        let filename = UUID().uuidString + ".mp3"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try data.write(to: fileURL)
        return fileURL
    }
}
