import UIKit

extension UIImage {
    @MainActor
    static func getOrFetch(from urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        if let cached = Database.shared.image(for: url) {
            return cached
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }

        Database.shared.storeUIImage(image, for: url)

        return image
    }
}
