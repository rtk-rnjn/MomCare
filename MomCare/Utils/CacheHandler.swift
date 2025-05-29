//
//  CacheHandler.swift
//  MomCare
//
//  Created by RITIK RANJAN on 28/05/25.
//

import Foundation
import UIKit
import OSLog

private var logger: Logger = .init(subsystem: "com.MomCare.CacheHandler", category: "Cache")

class CacheHandler {
    public static let shared: CacheHandler = .init()
    private var cache = NSCache<AnyObject, AnyObject>()

    func fetchImage(from url: URL) async -> UIImage? {
        if let cachedImage = cache.object(forKey: url as AnyObject) as? UIImage {
            logger.debug("Cache hit for URL: \(url.absoluteString)")
            return cachedImage
        }

        logger.debug("Cache miss for URL: \(url.absoluteString), fetching from network")

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            cache.setObject(image, forKey: url as AnyObject)
            return image
        } catch {
            logger.error("Failed to fetch image from URL: \(url.absoluteString), error: \(String(describing: error))")
            return nil
        }
    }

    func set<T>(_ value: T, forKey key: String) {
        cache.setObject(value as AnyObject, forKey: key as AnyObject)
        logger.debug("Set value for key: \(key)")
    }

    func get<T>(forKey key: String) -> T? {
        if let value = cache.object(forKey: key as AnyObject) as? T {
            logger.debug("Retrieved value for key: \(key)")
            return value
        }
        logger.debug("No value found for key: \(key)")
        return nil
    }
}
