import Foundation
import UIKit
import OSLog
import RealmSwift

/// Logger instance dedicated to cache operations within the `CacheHandler`.
private let logger: os.Logger = .init(
    subsystem: "com.MomCare.CacheHandler",
    category: "CacheHandler"
)

/// A generic wrapper object that associates a cached value with an expiration date.
///
/// `Entity` is used internally by `CacheHandler` to track both the value
/// and its validity window.
class Entity<T> {

    // MARK: Lifecycle

    /// Creates a new entity.
    ///
    /// - Parameters:
    ///   - value: The value to be stored. Defaults to `nil`.
    ///   - expiration: The date at which the value expires.
    ///     If `nil`, defaults to 24 hours from initialization.
    init(value: T? = nil, expiration: Date? = nil) {
        self.value = value
        self.expiration = expiration ?? Date().addingTimeInterval(60 * 60 * 24)
    }

    // MARK: Internal

    /// The cached value.
    var value: T?

    /// The expiration date of the cached value.
    var expiration: Date?

    /// Indicates whether the entity has expired.
    ///
    /// If no expiration date is set, the entity is considered non-expiring.
    var isExpired: Bool {
        guard let expiration else {
            return false
        }

        return Date() > expiration
    }
}

/// A lightweight, in-memory cache with optional expiration support.
///
/// `CacheHandler` stores values in an `NSCache` wrapped by an `Entity`
/// object that includes expiration handling.
/// Access is restricted to the main actor to ensure thread safety
/// when used alongside UIKit.
@MainActor
class CacheHandler: NSObject {

    // MARK: Public

    /// Underlying cache store. Values are wrapped in `Entity<T>`.
    ///
    /// Exposed as `public private(set)` to allow inspection
    /// but prevent uncontrolled mutation.
    public private(set) var cache: NSCache<AnyObject, AnyObject> = .init()

    // MARK: Internal

    /// Shared singleton instance for global access.
    static let shared: CacheHandler = .init()

    /// Stores a value in the cache with an optional expiration date.
    ///
    /// - Parameters:
    ///   - value: The value to store.
    ///   - key: A unique key identifying the cached value.
    ///   - expiration: An optional expiration date.
    ///     Defaults to 24 hours from the time of insertion if not specified.
    func set<T>(_ value: T, forKey key: String, expiration: Date? = nil) {
        let entity = Entity<T>(value: value, expiration: expiration)
        cache.setObject(entity as AnyObject, forKey: key as AnyObject)
        logger.debug("Set value for key: \(key)")
    }

    /// Retrieves a value from the cache if it exists and is not expired.
    ///
    /// - Parameters:
    ///   - key: The unique key associated with the cached value.
    ///   - expiration: Currently unused.
    ///     Reserved for potential future support of on-demand expiration updates.
    /// - Returns: The cached value if found and valid, otherwise `nil`.
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
