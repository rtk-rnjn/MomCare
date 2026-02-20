

import Combine
import SwiftUI

@MainActor
class MoodResultViewModel: ObservableObject {

    // MARK: Lifecycle

    init(mood: MoodType) {
        self.mood = mood
    }

    // MARK: Internal

    @Published var caption: String = "Loading affirmation..."
    @Published var songs: [SongModel] = []
    @Published var playlists: [PlaylistModel] = []
    @Published var isLoading: Bool = true

    let mood: MoodType

    func loadData() async {
        async let captionTask = fetchGeminiCaption()
        async let songsTask = fetchSongs(for: mood)

        caption = await captionTask
        songs = await songsTask
        playlists = PlaylistModel.from(allSongs: songs)
        isLoading = false
    }
}

extension MoodResultViewModel {
    func fetchGeminiCaption() async -> String {
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

    func fetchSongs(for moodType: MoodType) async -> [SongModel] {
        let networkResponse = try? await ContentService.shared.fetchSongs(for: moodType)
        return networkResponse?.data ?? []
    }
}
