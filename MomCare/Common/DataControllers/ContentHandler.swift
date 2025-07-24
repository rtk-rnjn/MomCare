//
//  ContentHandler.swift
//  MomCare
//
//  Created by RITIK RANJAN on 05/03/25.
//

import Foundation
import AVFoundation

@MainActor
class ContentHandler {

    // MARK: Internal

    static var shared: ContentHandler = .init()

    var plan: MyPlan? {
        get {
            return CacheHandler.shared.get(forKey: "plan")
        }
        set {
            CacheHandler.shared.set(newValue, forKey: "plan")
        }
    }

    var tips: Tip? {
        get {
            return CacheHandler.shared.get(forKey: "tips")
        }
        set {
            CacheHandler.shared.set(newValue, forKey: "tips")
        }
    }

    @discardableResult
    func fetchPlan(from userMedical: UserMedical) async -> MyPlan {
        if let plan {
            return plan
        }

        let plan: MyPlan? = await NetworkManager.shared.get(url: Endpoint.plan.urlString)
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

        let tips: Tip? = await NetworkManager.shared.get(url: Endpoint.tips.urlString)
        guard let tips else {
            return Tip(todaysFocus: "Unable to fetch Today's Focus from the server", dailyTip: "Unable to fetch Daily Tip from the server")
        }

        self.tips = tips
        return tips
    }

    func searchStreamedFood(with query: String, onItem: (@Sendable (FoodItem) -> Void)?) async {
        let searchQeury = FoodSearchQuery(foodName: query)
        let sendableQeury: [String: Any]? = searchQeury.toDictionary(snakeCase: true)

        await NetworkManager.shared.fetchStreamedData(.GET, url: Endpoint.search.urlString, queryParameters: sendableQeury, onItem: onItem)
    }

    func searchStreamedFoodName(with query: String, onItem: (@Sendable (FoodItem) -> Void)?) async {
        let searchQeury = FoodSearchQuery(foodName: query)
        let sendableQeury: [String: Any]? = searchQeury.toDictionary(snakeCase: true)

        await NetworkManager.shared.fetchStreamedData(.GET, url: Endpoint.searchFoodName.urlString, queryParameters: sendableQeury, onItem: onItem)
    }

    func fetchQuotes(for mood: MoodType) async -> String? {
        let cachedQuote: String? = CacheHandler.shared.get(forKey: mood.rawValue)
        if let cachedQuote {
            return cachedQuote
        }
        let quote: String? = await NetworkManager.shared.get(url: Endpoint.contentQuotesMood.urlString(with: mood.rawValue))

        CacheHandler.shared.set(quote, forKey: mood.rawValue)

        return quote
    }

    // MARK: Private

    private func fetchFromUserDefaults() -> Tip? {
        guard let data = UserDefaults.standard.data(forKey: "tips") else { return nil }

        return data.decode()
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
        let urlString = Endpoint.contentS3File.urlString(with: path)
        return await NetworkManager.shared.get(url: urlString)
    }

    func fetchS3Files(_ path: String) async -> [String]? {
        let urlString = Endpoint.contentS3Files.urlString(with: path)
        return await NetworkManager.shared.get(url: urlString)
    }

    func fetchS3Directories(_ path: String) async -> [String]? {
        let urlString = Endpoint.contentS3Directories.urlString(with: path)
        return await NetworkManager.shared.get(url: urlString)
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
            let label = extractLastPathComponent(from: directory)
            let imageUri = "\(directory)\(label.lowercased()).jpg"

            if let response = await fetchS3File(imageUri) {
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

            let urlString = Endpoint.contentS3Song.urlString(with: songPath)
            guard var songObject: Song = await NetworkManager.shared.get(url: urlString),
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

extension ContentHandler {
    func fetchExercises() async -> [Exercise]? {
//        let exercises: [Exercise]? = await NetworkManager.shared.get(url: Endpoint.exercises.urlString)
//        guard let exercises else {
//            return nil
//        }
        let exercises = [
            Exercise(name: "breath", type: .breathing, duration: 10, description: "breath", tags: ["h"], level: .beginner, week: "3", assignedAt: Date())
        ]
        
        return exercises
    }
}
