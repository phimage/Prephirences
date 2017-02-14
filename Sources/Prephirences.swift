//
//  Prephirences.swift
//  Prephirences
/*
The MIT License (MIT)

Copyright (c) 2017 Eric Marchand (phimage)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import Foundation

/* Preferences manager class that contains some Preferences */
open class Prephirences {

    /** Shared preferences. Could be replaced by any other preferences */
    open static var sharedInstance: PreferencesType = MutableDictionaryPreferences()

    // casting shortcut for sharedInstance
    open static var sharedMutableInstance: MutablePreferencesType? {
        return sharedInstance as? MutablePreferencesType
    }

    // MARK: register by key
    fileprivate static var _instances = [PrephirencesKey: PreferencesType]()

    /* Get Preferences for PrephirencesKey */
    fileprivate class func instance(forKey key: PrephirencesKey, orRegister newOne: PreferencesType? = nil) -> PreferencesType? {
        if let value = self._instances[key] {
            return value
        } else if let toRegister = newOne {
            registerInstance(toRegister, forKey: key)
        }
        return newOne
    }
    /* Add Preferences for PrephirencesKey */
    fileprivate class func register(preferences: PreferencesType, forKey key: PrephirencesKey) {
        self._instances[key] = preferences
    }
    /* Remove Preferences for PrephirencesKey */
    fileprivate class func unregisterPreferences(forKey key: PrephirencesKey) -> PreferencesType? {
        return self._instances.removeValue(forKey: key)
    }

    /* Get Preferences for key */
    open class func instance<Key: Hashable>(forKey key: Key, orRegister newOne: PreferencesType? = nil) -> PreferencesType? {
        return self.instance(forKey: PrephirencesKey(key), orRegister: newOne)
    }
    /* Add Preferences for key */
    open class func registerInstance<Key: Hashable>(_ preferences: PreferencesType, forKey key: Key) {
        self.register(preferences: preferences, forKey: PrephirencesKey(key))
    }
    /* Remove Preferences for key */
    open class func unregisterInstance<Key: Hashable>(forKey key: Key) -> PreferencesType? {
        return self.unregisterPreferences(forKey: PrephirencesKey(key))
    }

    /* allow to use subscript with desired key type */
    open static func instances<KeyType: Hashable>() -> PrephirencesForType<KeyType> {
        return PrephirencesForType<KeyType>()
    }

    static func isEmpty<T>(_ value: T?) -> Bool {
        return value == nil
    }

    open static func unraw<T>(_ object: T.RawValue?) -> T? where T: RawRepresentable, T.RawValue: PreferenceObject {
        if let rawValue = object {
            return T(rawValue: rawValue)
        }
        return nil
    }

    open static func raw<T>(_ value: T?) -> T.RawValue? where T: RawRepresentable, T.RawValue: PreferenceObject {
        return value?.rawValue
    }

}

/* Allow to access or modify Preferences according to key type */
open class PrephirencesForType<Key: Hashable> {

    open subscript(key: PreferenceKey) -> PreferencesType? {
        get {
            return Prephirences.instance(forKey: key)
        }
        set {
            if let value = newValue {
                Prephirences.registerInstance(value, forKey: key)
            } else {
                let _ = Prephirences.unregisterInstance(forKey: key)
            }
        }
    }

}

/* Generic key for dictionary */
struct PrephirencesKey: Hashable, Equatable {
    fileprivate let underlying: Any
    fileprivate let hashValueFunc: () -> Int
    fileprivate let equalityFunc: (Any) -> Bool

    init<T: Hashable>(_ key: T) {
        underlying = key
        hashValueFunc = { key.hashValue }
        equalityFunc = {
            if let other = $0 as? T {
                return key == other
            }
            return false
        }
    }

    var hashValue: Int { return hashValueFunc() }
}

internal func == (left: PrephirencesKey, right: PrephirencesKey) -> Bool {
    return left.equalityFunc(right.underlying)
}

// MARK: archive/unarchive

extension Prephirences {

    open static func unarchive(fromPreferences preferences: PreferencesType, forKey key: PreferenceKey) -> PreferenceObject? {
        if let data = preferences.data(forKey: key) {
            return unarchive(data)
        }
        return nil
    }

    open static func archive(object value: PreferenceObject?, intoPreferences preferences: MutablePreferencesType, forKey key: PreferenceKey) {
        if let toArchive: PreferenceObject = value {
            let data = archive(toArchive)
            preferences.set(data, forKey: key)
        } else {
            preferences.removeObject(forKey: key)
        }
    }

    open static func unarchive(_ data: Data) -> PreferenceObject? {
        return NSKeyedUnarchiver.unarchiveObject(with: data)
    }

    open static func archive(_ object: PreferenceObject) -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: object)
    }
}

extension PreferencesType {
    public func unarchiveObject(forKey key: PreferenceKey) -> PreferenceObject? {
        return Prephirences.unarchive(fromPreferences: self, forKey: key)
    }
}

extension MutablePreferencesType {
    public func set(objectToArchive value: PreferenceObject?, forKey key: PreferenceKey) {
        Prephirences.archive(object: value, intoPreferences: self, forKey: key)
    }
}
