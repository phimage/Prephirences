//
//  NSCache+Prephirences.swift
//  Prephirences
//
//  Created by phimage on 10/09/2017.
//  Copyright © 2017 phimage. All rights reserved.
//

import Foundation

public class NSCachePreferences<ObjectType>: MutablePreferencesType  where ObjectType: AnyObject {

    public let cache: NSCache<NSString, ObjectType>
    public var insertCost: Int = 0

    var _keys = Set<PreferenceKey>()

    // Init

    public init(cache: NSCache<NSString, ObjectType>) {
        self.cache = cache
    }

    // PreferencesType

    public func object(forKey key: PreferenceKey) -> PreferenceObject? {
        return self.cache.object(forKey: key as NSString)
    }

    // MutablePreferencesType

    public func set(_ value: PreferenceObject?, forKey key: PreferenceKey) {
        if let object = value as? ObjectType {
            self.cache.setObject(object, forKey: key as NSString, cost: insertCost)
            _keys.insert(key)
        } else {
           removeObject(forKey: key)
        }
    }

    public func removeObject(forKey key: PreferenceKey) {
        self.cache.removeObject(forKey: key as NSString)
        _keys.remove(key)
    }

    public func clearAll() {
        self.cache.removeAllObjects()
        _keys.removeAll()
    }

}

extension NSCachePreferences: PreferencesAdapter {

    public func keys() -> [String] {
        return Array(_keys)
    }

}
