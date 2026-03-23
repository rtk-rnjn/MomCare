import Foundation

actor CacheHandler {
    static let shared: CacheHandler = .init()

    private(set) var cache: NSCache<NSString, AnyObject> = .init()

    func set(_ value: any Codable, forKey key: NSString) {
        cache.setObject(value as AnyObject, forKey: key)
    }

    func get<T: Codable>(forKey key: NSString) -> T? {
        cache.object(forKey: key) as? T
    }

    func invalidate(forKey key: NSString) {
        cache.removeObject(forKey: key)
    }

    subscript<T: Codable>(key: NSString) -> T? {
        get {
            get(forKey: key)
        }

        set {
            if let newValue {
                set(newValue, forKey: key)
            } else {
                invalidate(forKey: key)
            }
        }
    }
}
