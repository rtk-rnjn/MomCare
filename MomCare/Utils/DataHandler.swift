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

    public private(set) var cache: NSCache<AnyObject, AnyObject> = .init()
}

class ImageCacheHandler: CacheHandler {
    public static let shared: ImageCacheHandler = .init()

    func fetchImage(from url: URL) async -> UIImage? {
        if let image = fetchFromCache(url: url) {
            return image
        }

        if let image = await fetchImageFromDatabase(url: url) {
            return image
        }

        return await fetchImageFromNetworkAndStore(url: url)
    }

    private func saveImageToDatabase(_ image: UIImage, url: URL, data: Data) async {
        let imageObject = Images()
        imageObject.uri = url.absoluteString
        imageObject.imageData = data
        await RealmHandler.shared.save(imageObject)
    }

    private func fetchImageFromDatabase(url: URL) async -> UIImage? {
        let predicate = NSPredicate(format: "url == %@", url.absoluteString)
        let realmResult = await RealmHandler.shared.fetchFirst(Images.self, predicate: predicate)

        if let imageData = realmResult?.imageData, let image = UIImage(data: imageData) {
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

            saveToCache(image, for: url)
            await saveImageToDatabase(image, url: url, data: data)
            return image
        } catch {
            logger.error("Failed to fetch image from URL: \(url.absoluteString), error: \(String(describing: error))")
            return nil
        }
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
        cache.setObject(entity, forKey: url as AnyObject)
    }
}


class RealmHandler {


    private init() {
        do {
            realm = try Realm()
            logger.debug("Realm initialized successfully")
        } catch {
            logger.error("Failed to initialize Realm: \(String(describing: error))")
            realm = nil
        }
    }


    @MainActor static let shared: RealmHandler = .init()

    let realm: Realm?

    private func write(_ block: (Realm) throws -> Void) {
        guard let realm else { return }
        do {
            try realm.write {
                try block(realm)
            }
        } catch {
            logger.error("Realm write error: \(String(describing: error))")
        }
    }

    func save<T: Object>(_ object: T) {
        write { realm in
            realm.add(object, update: .modified)
        }
        logger.debug("Saved object of type \(T.self) to Realm")
    }

    func fetch<T: Object>(_ type: T.Type, predicate: NSPredicate? = nil) -> Results<T>? {
        guard let realm else {
            logger.error("Failed to fetch objects of type \(T.self): Realm is nil")
            return nil
        }
        let results = realm.objects(type).filter(predicate ?? NSPredicate(value: true))
        logger.debug("Fetched \(results.count) objects of type \(T.self) from Realm")
        return results
    }

    func fetchFirst<T: Object>(_ type: T.Type, predicate: NSPredicate? = nil) -> T? {
        guard let realm else {
            logger.error("Failed to fetch first object of type \(T.self): Realm is nil")
            return nil
        }
        let results = realm.objects(type).filter(predicate ?? NSPredicate(value: true))
        logger.debug("Fetched first object of type \(T.self) from Realm")
        return results.first
    }

    func delete<T: Object>(_ object: T) {
        write { realm in
            realm.delete(object)
        }
        logger.debug("Deleted object of type \(T.self) from Realm")
    }

    func deleteAll<T: Object>(_ type: T.Type) {
        write { realm in
            realm.delete(realm.objects(type))
        }
        logger.debug("Deleted all objects of type \(T.self) from Realm")
    }

    func update<T: Object>(_ object: T, with block: (T) -> Void) {
        write { realm in
            block(object)
            realm.add(object, update: .modified)
        }
        logger.debug("Updated object of type \(T.self) in Realm")
    }

    func observe<T: Object>(_ type: T.Type, predicate: NSPredicate? = nil, completion: @escaping (Results<T>) -> Void) -> (notification: NotificationToken, realm: Realm)? {
        guard let realm else {
            logger.error("Failed to observe objects of type \(T.self): Realm is nil")
            return nil
        }
        let results = realm.objects(type).filter(predicate ?? NSPredicate(value: true))
        let token = results.observe { changes in
            switch changes {
            case .initial(let results):
                completion(results)
            case .update(let results, _, _, _):
                completion(results)
            case .error(let error):
                logger.error("Realm observation error: \(String(describing: error))")
            }
        }
        return (notification: token, realm: realm)
    }

}
