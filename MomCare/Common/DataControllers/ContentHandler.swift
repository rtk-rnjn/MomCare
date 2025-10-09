//
//  ContentHandler.swift
//  MomCare
//
//  Created by RITIK RANJAN on 05/03/25.
//

import Foundation
import AVFoundation

/// Centralized content manager for fetching and caching user-facing data.
///
/// `ContentHandler` provides high-level access to various pieces of content
/// required by **MomCare**, including:
/// - The user’s current plan (`MyPlan`)
/// - Daily focus tips (`Tips`)
/// - Food search results (`FoodItem`)
/// - Mood-based quotes (`String`)
///
/// Internally, it:
/// - Fetches fresh data via `NetworkManager`
/// - Caches frequently used results using `CacheHandler`
/// - Persists tips locally with `UserDefaults`
///
/// Use this class instead of directly calling `NetworkManager` when you want
/// cached data support and higher-level domain objects.
@MainActor
class ContentHandler {

    // MARK: Internal

    /// Shared global instance for content access.
    static var shared: ContentHandler = .init()

    /// Cached copy of the user’s current plan.
    ///
    /// - Stored in `CacheHandler` under the key `"plan"`.
    /// - If not available, fetch a new plan via ``fetchPlan(from:)``.
    var plan: MyPlan? {
        didSet {
            CacheHandler.shared.set(plan, forKey: "plan")
        }
    }

    /// Cached copy of today’s tips.
    ///
    /// - Stored in `CacheHandler` under the key `"tips"`.
    /// - If not available, fetch fresh tips via ``fetchTips(from:)``.
    var tips: Tips? {
        didSet {
            CacheHandler.shared.set(tips, forKey: "tips")
        }
    }

    /// Fetches the user’s plan, either from cache or the backend.
    ///
    /// - Parameter userMedical: The user’s medical details (not currently used but
    ///   provided for future API personalization).
    /// - Returns: A `MyPlan` object. If the server fetch fails, returns an empty plan.
    @discardableResult
    func fetchPlan(from userMedical: UserMedical) async -> MyPlan {
        if let plan: MyPlan = CacheHandler.shared.get(forKey: "plan") {
            return plan
        }

        let plan: MyPlan? = await NetworkManager.shared.get(url: Endpoint.plan.urlString)
        guard let plan else {
            return MyPlan()
        }

        self.plan = plan
        return plan
    }

    /// Fetches today’s tips, either from cache or the backend.
    ///
    /// - Parameter user: The current user (not currently used but
    ///   provided for future API personalization).
    /// - Returns: A `Tips` object. If the server fetch fails, returns a fallback `Tips`
    ///   with default error messages.
    @discardableResult
    func fetchTips(from user: User) async -> Tips {
        if let tips: Tips = CacheHandler.shared.get(forKey: "tips") {
            return tips
        }

        let tips: Tips? = await NetworkManager.shared.get(url: Endpoint.tips.urlString)
        guard let tips else {
            return Tips(
                todaysFocus: "Unable to fetch Today's Focus from the server",
                dailyTip: "Unable to fetch Daily Tip from the server"
            )
        }

        self.tips = tips
        return tips
    }

    /// Performs a streamed search for food items.
    ///
    /// - Parameters:
    ///   - query: The user’s search string (e.g., `"apple"`).
    ///   - onItem: Closure invoked for each decoded `FoodItem` as it arrives from the stream.
    func searchStreamedFood(
        with query: String,
        onItem: (@Sendable (FoodItem) -> Void)?
    ) async {
        let searchQuery = FoodSearchQuery(foodName: query)
        let sendableQuery: [String: Any]? = searchQuery.toDictionary(snakeCase: true)

        await NetworkManager.shared.fetchStreamedData(
            .GET,
            url: Endpoint.search.urlString,
            queryParameters: sendableQuery,
            onItem: onItem
        )
    }

    /// Performs a streamed search for food names only (lighter API variant).
    ///
    /// - Parameters:
    ///   - query: The user’s search string (e.g., `"rice"`).
    ///   - onItem: Closure invoked for each decoded `FoodItem` as it arrives.
    func searchStreamedFoodName(
        with query: String,
        onItem: (@Sendable (FoodItem) -> Void)?
    ) async {
        let searchQuery = FoodSearchQuery(foodName: query)
        let sendableQuery: [String: Any]? = searchQuery.toDictionary(snakeCase: true)

        await NetworkManager.shared.fetchStreamedData(
            .GET,
            url: Endpoint.searchFoodName.urlString,
            queryParameters: sendableQuery,
            onItem: onItem
        )
    }

    /// Fetches a motivational quote for a given mood.
    ///
    /// - Parameter mood: The user’s current `MoodType`.
    /// - Returns: A motivational quote string, either from cache or the backend.
    ///
    /// Quotes are cached in `CacheHandler` under the mood’s raw value.
    func fetchQuotes(for mood: MoodType) async -> String? {
        if let cachedQuote: String = CacheHandler.shared.get(forKey: mood.rawValue) {
            return cachedQuote
        }

        let quote: String? = await NetworkManager.shared.get(
            url: Endpoint.contentQuotesMood.urlString(with: mood.rawValue)
        )
        CacheHandler.shared.set(quote, forKey: mood.rawValue)

        return quote
    }

    // MARK: Private

    /// Retrieves tips from `UserDefaults`, if available.
    private func fetchFromUserDefaults() -> Tips? {
        guard let data = UserDefaults.standard.data(forKey: "tips") else { return nil }
        return data.decodeUsingJSONDecoder()
    }

    /// Persists tips to `UserDefaults` for offline access.
    private func saveToUserDefaults(_ tips: Tips) {
        guard let data = tips.toData() else { return }
        UserDefaults.standard.set(data, forKey: "tips")
    }
}

extension ContentHandler {

    /// Fetches a single S3 file’s metadata from the server.
    ///
    /// - Parameter path: The relative path or key of the file in S3.
    /// - Returns: An optional `S3Response` containing the pre-signed URL and
    ///   optional expiry date. Returns `nil` if the request fails.
    func fetchS3File(_ path: String) async -> S3Response? {
        let urlString = Endpoint.contentS3File.urlString(with: path)
        return await NetworkManager.shared.get(url: urlString)
    }

    /// Fetches multiple S3 file names at a given path.
    ///
    /// - Parameter path: The relative directory path in S3.
    /// - Returns: An optional array of file names (`[String]`), or `nil` if the request fails.
    func fetchS3Files(_ path: String) async -> [String]? {
        let urlString = Endpoint.contentS3Files.urlString(with: path)
        return await NetworkManager.shared.get(url: urlString)
    }

    /// Fetches S3 subdirectories at a given path.
    ///
    /// - Parameter path: The relative parent directory path in S3.
    /// - Returns: An optional array of directory names (`[String]`), or `nil` if the request fails.
    func fetchS3Directories(_ path: String) async -> [String]? {
        let urlString = Endpoint.contentS3Directories.urlString(with: path)
        return await NetworkManager.shared.get(url: urlString)
    }
}

extension ContentHandler {

    /// Fetches playlists for a given mood.
    ///
    /// Each playlist consists of a tuple containing:
    /// - `imageUri`: The URI of the playlist cover image.
    /// - `label`: The playlist name extracted from the directory.
    ///
    /// - Parameter forMood: The user’s current mood.
    /// - Returns: An optional array of playlists. Returns `nil` if no playlists are found.
    func fetchPlaylists(forMood: MoodType) async -> [(imageUri: String, label: String)]? {
        let directories = await getMoodDirectories(forMood)
        guard !directories.isEmpty else { return nil }

        return await buildPlaylistData(from: directories)
    }

    /// Retrieves the S3 directories for a specific mood.
    ///
    /// - Parameter mood: The mood to fetch directories for.
    /// - Returns: An array of directory paths (may be empty if none found).
    private func getMoodDirectories(_ mood: MoodType) async -> [String] {
        let moodValue = mood.rawValue
        return await fetchS3Directories("Songs/\(moodValue)/") ?? []
    }

    /// Constructs playlist data from S3 directories.
    ///
    /// - Parameter directories: List of S3 directories representing playlists.
    /// - Returns: Array of tuples containing `imageUri` and playlist `label`.
    private func buildPlaylistData(from directories: [String]) async -> [(imageUri: String, label: String)] {
        var result = [(imageUri: String, label: String)]()

        for directory in directories where !directory.isEmpty {
            let label = extractLastPathComponent(from: directory)
            let imageUri = "\(directory)\(label.lowercased()).jpg"

            if let response = await fetchS3File(imageUri) {
                result.append((imageUri: response.uri, label: label))
            }
        }

        return result
    }

    /// Extracts the last component of a path.
    ///
    /// - Parameter path: Full path string.
    /// - Returns: Last component (e.g., folder or file name) without trailing slashes.
    private func extractLastPathComponent(from path: String) -> String {
        path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            .components(separatedBy: "/")
            .last ?? ""
    }

    /// Fetches songs for a specific playlist and mood.
    ///
    /// Each `Song` object will have its `imageUri` populated with the
    /// corresponding playlist cover or song image.
    ///
    /// - Parameters:
    ///   - forMood: The user’s mood.
    ///   - playlistName: The playlist name.
    /// - Returns: Array of `Song` objects, or `nil` if no songs are found.
    func fetchPlaylistSongs(forMood: MoodType, playlistName: String) async -> [Song]? {
        let (songsPath, imagePath) = getPaths(forMood: forMood, playlistName: playlistName)

        let paths = await fetchS3Files(songsPath) ?? []
        let images = await fetchS3Files(imagePath) ?? []
        let imageNames = extractFilenames(from: images)

        return await matchSongsToImages(songsPath: paths, imageNames: imageNames, imagePath: imagePath)
    }

    /// Computes S3 paths for songs and images for a given playlist.
    private func getPaths(forMood: MoodType, playlistName: String) -> (String, String) {
        let base = "Songs/\(forMood.rawValue)/\(playlistName)"
        return ("\(base)/Song/", "\(base)/Image/")
    }

    /// Extracts filenames from full S3 paths.
    private func extractFilenames(from paths: [String]) -> [String] {
        paths.map { path in
            let components = path.split(separator: "/")
            return String(components.last ?? "")
        }
    }

    /// Matches songs to their corresponding images and fetches metadata.
    private func matchSongsToImages(songsPath: [String], imageNames: [String], imagePath: String) async -> [Song] {
        var result = [Song]()

        for songPath in songsPath {
            guard let imageFile = findMatchingImage(for: songPath, from: imageNames) else { continue }

            let fullImagePath = "\(imagePath)\(imageFile)"
            let actualImageUri = await fetchS3File(fullImagePath)?.uri

            let urlString = Endpoint.contentS3Song.urlString(with: songPath)
            guard var songObject: Song = await NetworkManager.shared.get(url: urlString),
                  let actualImageUri else { continue }
//            downloadAndStoreSong(from:)

            songObject.imageUri = actualImageUri
            result.append(songObject)
        }

        return result
    }

    /// Finds the best matching image for a given song name.
    private func findMatchingImage(for song: String, from imageNames: [String]) -> String? {
        let songKey = song.lowercased().replacingOccurrences(of: " ", with: "")
        return imageNames.first { image in
            let name = image.split(separator: ".").first?
                .replacingOccurrences(of: " ", with: "")
                .lowercased()
            return name.map { songKey.contains($0) } ?? false
        }
    }

    /// Downloads a song from a given URI and stores it in a temporary file.
    ///
    /// - Parameter uri: Remote URI of the song file.
    /// - Returns: URL of the downloaded temporary file, or `nil` if download fails.
    func downloadSong(from uri: String) async -> URL? {
        do {
            return try await downloadAndStoreSong(from: uri)
        } catch {
            return nil
        }
    }

    /// Downloads a song and writes it to the temporary directory.
    ///
    /// - Parameter uri: Remote URI of the song file.
    /// - Throws: `URLError.badURL` if the URL is invalid or other I/O errors.
    /// - Returns: Local file URL of the downloaded song.
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

    /// Fetches the list of exercises from the backend.
    ///
    /// - Returns: An optional array of `Exercise` objects. Returns `nil` if the network
    ///   request fails or no exercises are available.
    func fetchExercises() async -> [Exercise]? {
        let exercises: [Exercise]? = await NetworkManager.shared.get(url: Endpoint.exercises.urlString)
        guard let exercises else {
            return nil
        }

        return exercises
    }
}
