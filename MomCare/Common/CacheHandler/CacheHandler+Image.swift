import Foundation
import UIKit
import RealmSwift
import OSLog

/// Logger instance dedicated to cache operations within the `CacheHandler`.
private let logger: os.Logger = .init(
    subsystem: "com.MomCare.CacheHandler",
    category: "CacheHandler"
)

extension CacheHandler {

    /// Fetches an image for the given URL, resolving through multiple sources.
    ///
    /// The lookup order is:
    /// 1. In-memory cache
    /// 2. Normalized S3 link (if applicable)
    /// 3. Realm database
    /// 4. Network request (and persists result in cache + database)
    ///
    /// - Parameter url: The URL of the image.
    /// - Returns: The fetched `UIImage` if found or downloaded, otherwise `nil`.
    func fetchImage(from url: URL) async -> UIImage? {
        if let image = fetchFromCache(url: url) {
            return image
        }

        let s3Link = parseIfS3Link(url: url)
        if let image = fetchFromCache(url: s3Link) {
            return image
        }

        if let image = fetchImageFromDatabase(url: url) {
            return image
        }

        return await fetchImageFromNetworkAndStore(url: url)
    }

    /// Saves an image to the Realm database asynchronously in a background task.
    ///
    /// - Parameters:
    ///   - image: The `UIImage` being stored.
    ///   - url: The source URL of the image.
    ///   - data: The raw image data for serialization.
    private func saveImageToDatabase(_ image: UIImage, url: URL, data: Data) {
        Task.detached(priority: .background) {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    let imageObject = Images()
                    imageObject.uri = url.absoluteString
                    imageObject.imageData = data

                    try realm.write {
                        realm.add(imageObject, update: .modified)
                    }
                } catch {
                    logger.error("Realm write failed: \(String(describing: error))")
                }
            }
        }
    }

    /// Attempts to fetch an image from the Realm database.
    ///
    /// - Parameter url: The source URL of the image.
    /// - Returns: The `UIImage` if found and successfully decoded, otherwise `nil`.
    ///
    /// - Note: On a successful hit, the image is also written back into the in-memory cache.
    private func fetchImageFromDatabase(url: URL) -> UIImage? {
        let realm = try? Realm()
        let results = realm?.objects(Images.self).filter("uri == %@", url.absoluteString)

        if let imageData = results?.first?.imageData,
           let image = UIImage(data: imageData) {
            logger.debug("Image found in Realm for URL: \(url.absoluteString)")
            saveToCache(image, for: url)
            return image
        }

        logger.debug("Image data is nil for URL: \(url.absoluteString)")
        return nil
    }

    /// Fetches an image from the network and persists it in both cache and Realm.
    ///
    /// - Parameter url: The source URL of the image.
    /// - Returns: The downloaded `UIImage` if successful, otherwise `nil`.
    private func fetchImageFromNetworkAndStore(url: URL) async -> UIImage? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }

            let url = parseIfS3Link(url: url)

            saveToCache(image, for: url)
            saveImageToDatabase(image, url: url, data: data)
            return image
        } catch {
            logger.error("Failed to fetch image from URL: \(url.absoluteString), error: \(String(describing: error))")
            return nil
        }
    }

    /// Normalizes an S3 link by stripping query parameters.
    ///
    /// - Parameter url: The original URL, possibly including S3 query params.
    /// - Returns: A canonicalized URL without query components.
    private func parseIfS3Link(url: URL) -> URL {
        if !url.absoluteString.contains("amazonaws.com") {
            return url
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.query = nil
        guard let url = components?.url else {
            logger.error("Failed to parse URL: \(url.absoluteString)")
            return url
        }

        return url
    }

    /// Retrieves an image from the in-memory cache.
    ///
    /// - Parameter url: The cache key, derived from the image URL.
    /// - Returns: The cached image if found and not expired, otherwise `nil`.
    private func fetchFromCache(url: URL) -> UIImage? {
        if let cachedImage = cache.object(forKey: url as AnyObject) as? Entity<UIImage> {
            logger.debug("Cache hit for URL: \(url.absoluteString)")
            if cachedImage.isExpired {
                logger.debug("Cached image expired for URL: \(url.absoluteString)")
                return nil
            }
            return cachedImage.value
        }

        logger.debug("Cache miss for URL: \(url.absoluteString)")
        return nil
    }

    /// Saves an image to the in-memory cache with a default expiration (24 hours).
    ///
    /// - Parameters:
    ///   - image: The `UIImage` to be cached.
    ///   - url: The cache key corresponding to the image.
    private func saveToCache(_ image: UIImage, for url: URL) {
        let entity = Entity<UIImage>(value: image)
        logger.debug("Saving image to cache for URL: \(url.absoluteString)")
        cache.setObject(entity, forKey: url as AnyObject)
    }
}
