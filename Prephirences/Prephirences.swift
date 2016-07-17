//
//  Prephirences.swift
//  Prephirences
/*
The MIT License (MIT)

Copyright (c) 2015 Eric Marchand (phimage)

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
public class Prephirences {

    /** Shared preferences. Could be replaced by any other preferences */
    public static var sharedInstance: PreferencesType = MutableDictionaryPreferences()
    
    // casting shortcut for sharedInstance
    public static var sharedMutableInstance: MutablePreferencesType? {
        return sharedInstance as? MutablePreferencesType
    }

    // MARK: register by key
    private static var _instances: Dictionary<PrephirencesKey,PreferencesType> = Dictionary<PrephirencesKey,PreferencesType>()

    /* Get Preferences for PrephirencesKey */
    private class func instanceForKey(key: PrephirencesKey, orRegister newOne: PreferencesType? = nil) -> PreferencesType?{
        if let value = self._instances[key] {
            return value
        }
        else if let toRegister = newOne {
            registerInstance(toRegister, forKey: key)
        }
        return newOne
    }
    /* Add Preferences for PrephirencesKey */
    private class func registerPreferences(preferences: PreferencesType, forKey key: PrephirencesKey) {
        self._instances[key] = preferences
    }
    /* Remove Preferences for PrephirencesKey */
    private class func unregisterPreferencesForKey(key: PrephirencesKey) -> PreferencesType? {
        return self._instances.removeValueForKey(key)
    }

    /* Get Preferences for key */
    public class func instanceForKey<Key: Hashable>(key: Key, orRegister newOne: PreferencesType? = nil) -> PreferencesType?{
        return self.instanceForKey(PrephirencesKey(key), orRegister: newOne)
    }
    /* Add Preferences for key */
    public class func registerInstance<Key: Hashable>(preferences: PreferencesType, forKey key: Key) {
        self.registerPreferences(preferences, forKey: PrephirencesKey(key))
    }
    /* Remove Preferences for key */
    public class func unregisterInstanceForKey<Key: Hashable>(key: Key) -> PreferencesType? {
        return self.unregisterPreferencesForKey(PrephirencesKey(key))
    }

    /* allow to use subscript with desired key type */
    public static func instances<KeyType: Hashable>() -> PrephirencesForType<KeyType> {
        return PrephirencesForType<KeyType>()
    }
    
    // MARK: archive/unarchive
    public static func unarchiveObject(preferences: PreferencesType, forKey key: String) -> AnyObject? {
        if let data = preferences.dataForKey(key) {
            return unarchive(data)
        }
        return nil
    }
    
    public static func archiveObject(value: AnyObject?, preferences: MutablePreferencesType, forKey key: String){
        if let toArchive: AnyObject = value {
            let data = archive(toArchive)
            preferences.setObject(data, forKey: key)
        }
        else {
            preferences.removeObjectForKey(key)
        }
    }
    
    public static func unarchive(data: NSData) -> AnyObject? {
        return NSKeyedUnarchiver.unarchiveObjectWithData(data)
    }
    
    public static func archive(object: AnyObject) -> NSData {
        return NSKeyedArchiver.archivedDataWithRootObject(object)
    }
    
    static func isEmpty<T>(value: T?) -> Bool {
        return value == nil
    }

    public static func unraw<T where T: RawRepresentable, T.RawValue: AnyObject>(object: T.RawValue?) -> T? {
        if let rawValue = object {
            return T(rawValue: rawValue)
        }
        return nil
    }
    
    public static func raw<T where T: RawRepresentable, T.RawValue: AnyObject>(value: T?) -> T.RawValue? {
        return value?.rawValue
    }

    // MARK: deprecated
    @available(*, deprecated=1, message="Please use ProxyPreferences(preferences: preferences).")
    public static func immutableProxy(preferences: MutablePreferencesType) -> PreferencesType {
        return ProxyPreferences(preferences: preferences)
    }
    @available(*, deprecated=1, message="Please use MutablePreference<T>(preferences: preferences, key: key).")
    public static func preferenceForKey<T>(key: String,_ preferences: MutablePreferencesType) -> MutablePreference<T> {
        return MutablePreference<T>(preferences: preferences, key: key)
    }
    @available(*, deprecated=1, message="Please use Preference<T>(preferences: preferences, key: key).")
    public static func preferenceForKey<T>(key: String,_ preferences: PreferencesType) -> Preference<T> {
        return Preference<T>(preferences: preferences, key: key)
    }
}

/* Allow to access or modify Preferences according to key type */
public class PrephirencesForType<Key: Hashable> {
    
    public subscript(key: Key) -> PreferencesType? {
        get {
            return Prephirences.instanceForKey(key)
        }
        set {
            if let value = newValue {
                Prephirences.registerInstance(value, forKey: key)
            }
            else {
                Prephirences.unregisterInstanceForKey(key)
            }
        }
    }

}

/* Generic key for dictionary */
struct PrephirencesKey: Hashable, Equatable {
    private let underlying: Any
    private let hashValueFunc: () -> Int
    private let equalityFunc: (Any) -> Bool
    
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

internal func ==(x: PrephirencesKey, y: PrephirencesKey) -> Bool {
    return x.equalityFunc(y.underlying)
}