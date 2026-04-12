import HealthKit

extension ContentServiceHandler {
    func fetchMoodNestData(for mood: MoodType) async throws {
        async let captionTask = fetchGeminiCaption(for: mood)
        moodNestCaption = await captionTask
        songs = try await fetchSongs(for: mood)
        playlists = PlaylistModel.from(allSongs: songs)
    }

    func fetchGeminiCaption(for mood: MoodType) async -> String {
        switch mood {
        case .happy:
            "Your joy is beautiful, and you're creating a loving world for your baby."
        case .sad:
            "It's okay to feel low. You are still strong, caring, and deeply loved."
        case .stressed:
            "Take a breath. You're doing better than you think, one gentle step at a time."
        case .angry:
            "Your anger is valid, your feelings matter, and you're still going to be an amazing mother."
        }
    }

    func fetchSongs(for moodType: MoodType) async throws -> [SongModel] {
        let networkResponse = try await MCContentRepository.shared.fetchSongs(for: moodType)
        return networkResponse.data
    }

    @available(iOS 18.0, *)
    func logMoodToHealthKit(mood: MoodType) async throws {
        let kind = HKStateOfMind.Kind.momentaryEmotion
        let valence: Double = mood.valence
        let label = mood.label
        let sample = HKStateOfMind(date: .init(), kind: kind, valence: valence, labels: [label], associations: [])

        try await healthStore.save(sample)
    }
}
