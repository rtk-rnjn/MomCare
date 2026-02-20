//
//  CacheHandler.swift
//  MomCare+
//
//  Created by Aryan singh on 12/02/26.
//

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
}
