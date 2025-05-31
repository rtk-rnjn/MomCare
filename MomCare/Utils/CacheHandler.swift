//
//  CacheHandler.swift
//  MomCare
//
//  Created by RITIK RANJAN on 28/05/25.
//

import Foundation
import UIKit
import OSLog

private let logger: Logger = .init(subsystem: "com.MomCare.CacheHandler", category: "Cache")

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

    // MARK: Internal

    @MainActor static let shared: CacheHandler = .init()

    func fetchImage(from url: URL) async -> UIImage? {
        if let cachedImage = cache.object(forKey: url as AnyObject) as? Entity<UIImage> {
            logger.debug("Cache hit for URL: \(url.absoluteString)")
            if cachedImage.isExpired {
                logger.debug("Cached image expired for URL: \(url.absoluteString), fetching from network")
            } else {
                return cachedImage.value
            }
        }

        logger.debug("Cache miss for URL: \(url.absoluteString), fetching from network")

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }

            let entity = Entity<UIImage>(value: image)
            cache.setObject(entity, forKey: url as AnyObject)
            return image
        } catch {
            logger.error("Failed to fetch image from URL: \(url.absoluteString), error: \(String(describing: error))")
            return nil
        }
    }

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

    // MARK: Private

    private var cache: NSCache<AnyObject, AnyObject> = .init()

}
