//
//  DataHandler.swift
//  MomCare
//
//  Created by RITIK RANJAN on 28/05/25.
//

import Foundation
import UIKit
import OSLog
import RealmSwift

private let logger: os.Logger = .init(subsystem: "com.MomCare.DataHandler", category: "Cache")

class Entity<T> {

    // MARK: Lifecycle

    init(value: T? = nil, expiration: Date? = nil) {
        self.value = value
        self.expiration = expiration ?? Date().addingTimeInterval(60 * 60 * 24)
    }

    // MARK: Internal

    var value: T?
    var expiration: Date?

    var isExpired: Bool {
        guard let expiration else {
            return false
        }

        return Date() > expiration
    }

}

class CacheHandler {

    // MARK: Public

    public private(set) var cache: NSCache<AnyObject, AnyObject> = .init()

    // MARK: Internal

    @MainActor static let shared: CacheHandler = .init()

    func set<T>(_ value: T, forKey key: String, expiration: Date? = nil) {
        let entity = Entity<T>(value: value, expiration: expiration)
        cache.setObject(entity as AnyObject, forKey: key as AnyObject)
        logger.debug("Set value for key: \(key)")
    }

    func get<T>(forKey key: String, expiration: Date? = nil) -> T? {
        if let entity = cache.object(forKey: key as AnyObject) as? Entity<T> {
            logger.debug("Retrieved value for key: \(key)")
            if entity.isExpired {
                logger.debug("Value for key: \(key) is expired, removing from cache")
                cache.removeObject(forKey: key as AnyObject)
            } else {
                return entity.value
            }
        }
        logger.debug("No value found for key: \(key)")
        return nil
    }

}

extension CacheHandler {

    // MARK: Internal

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

    // MARK: Private

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

    private func fetchImageFromDatabase(url: URL) -> UIImage? {
        let realm = try? Realm()
        let results = realm?.objects(Images.self).filter("uri == %@", url.absoluteString)

        if let imageData = results?.first?.imageData, let image = UIImage(data: imageData) {
            logger.debug("Image found in Realm for URL: \(url.absoluteString)")
            saveToCache(image, for: url)
            return image
        }

        logger.debug("Image data is nil for URL: \(url.absoluteString)")
        return nil
    }

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

    private func fetchFromCache(url: URL) -> UIImage? {
        if let cachedImage = cache.object(forKey: url as AnyObject) as? Entity<UIImage> {
            logger.debug("Cache hit for URL: \(url.absoluteString)")
            if cachedImage.isExpired {
                logger.debug("Cached image expired for URL: \(url.absoluteString), fetching from network")
                return nil
            }
            return cachedImage.value
        }

        logger.debug("Cache miss for URL: \(url.absoluteString), fetching from internal database")
        return nil
    }

    private func saveToCache(_ image: UIImage, for url: URL) {
        let entity = Entity<UIImage>(value: image)
        logger.debug("Saving image to cache for URL: \(url.absoluteString)")
        cache.setObject(entity, forKey: url as AnyObject)
    }
}
