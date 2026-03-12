import Foundation

extension SongModel {
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
