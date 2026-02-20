import UIKit

extension UIImage {
    static func getOrFetch(from urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        if let cached = Database().image(for: url) {
            return cached
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }

        Database().storeUIImage(image, for: url)

        return image
    }
}
