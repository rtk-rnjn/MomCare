import Foundation

extension SongModel {
    var url: URL? {
        get async {
            guard let networkResponse = try? await ContentRepository.shared.fetchSongStreamUri(id: _id) else {
                return nil
            }

            return URL(string: networkResponse.data.detail)
        }
    }
}
