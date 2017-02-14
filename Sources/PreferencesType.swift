//
//  PreferencesType.swift
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

public typealias PreferenceObject = Any
public typealias PreferenceKey = String
public typealias PreferencesDictionary = [PreferenceKey: PreferenceObject]

// MARK: - Preferences
public protocol PreferencesType {

    func object(forKey key: PreferenceKey) -> PreferenceObject?
    func dictionary() -> PreferencesDictionary

    // MARK: Optional methods
    subscript(key: PreferenceKey) -> PreferenceObject? {get}
    func hasObject(forKey: PreferenceKey) -> Bool

    func string(forKey: PreferenceKey) -> String?
    func array(forKey: PreferenceKey) -> [PreferenceObject]?
    func dictionary(forKey: PreferenceKey) -> PreferencesDictionary?
    func stringArray(forKey: PreferenceKey) -> [String]?
    func integer(forKey: PreferenceKey) -> Int
    func float(forKey: PreferenceKey) -> Float
    func double(forKey: PreferenceKey) -> Double
    func bool(forKey: PreferenceKey) -> Bool

    func data(forKey: PreferenceKey) -> Data?
    func url(forKey: PreferenceKey) -> URL?

    func unarchiveObject(forKey: PreferenceKey) -> PreferenceObject?

}

// MARK: - Mutable Preferences
public protocol MutablePreferencesType: PreferencesType {

    func set(_ value: PreferenceObject?, forKey key: PreferenceKey)
    func removeObject(forKey key: PreferenceKey)

    // MARK: Optional methods

    subscript(key: PreferenceKey) -> PreferenceObject? {get set}

    func set(_ value: Int, forKey key: PreferenceKey)
    func set(_ value: Float, forKey key: PreferenceKey)
    func set(_ value: Double, forKey key: PreferenceKey)
    func set(_ value: Bool, forKey key: PreferenceKey)
    func set(_ value: URL?, forKey key: PreferenceKey)

    func set(objectToArchive value: PreferenceObject?, forKey key: PreferenceKey)

    func clearAll()
    func set(dictionary: PreferencesDictionary)
}

// MARK: - Default implementations for optional methods
public extension PreferencesType {

    subscript(key: PreferenceKey) -> PreferenceObject? {
        return object(forKey: key)
    }
    public func hasObject(forKey key: PreferenceKey) -> Bool {
        return self.object(forKey: key) != nil
    }

    public func string(forKey key: PreferenceKey) -> String? {
        return self.object(forKey: key) as? String
    }
    public func array(forKey key: PreferenceKey) -> [PreferenceObject]? {
        return self.object(forKey: key) as? [AnyObject]
    }
    public func dictionary(forKey key: PreferenceKey) -> PreferencesDictionary? {
        return self.object(forKey: key) as? [String : AnyObject]
    }
    public func data(forKey key: PreferenceKey) -> Data? {
        return self.object(forKey: key) as? Data
    }
    public func stringArray(forKey key: PreferenceKey) -> [String]? {
        return self.object(forKey: key) as? [String]
    }
    public func integer(forKey key: PreferenceKey) -> Int {
        return self.object(forKey: key) as? Int ?? 0
    }
    public func float(forKey key: PreferenceKey) -> Float {
        return self.object(forKey: key) as? Float ?? 0
    }
    public func double(forKey key: PreferenceKey) -> Double {
        return self.object(forKey: key) as? Double ?? 0
    }
    public func bool(forKey key: PreferenceKey) -> Bool {
        return self.object(forKey: key) as? Bool ?? false
    }
    public func url(forKey key: PreferenceKey) -> URL? {
        return self.object(forKey: key) as? URL
    }

}

public extension MutablePreferencesType {

    public subscript(key: PreferenceKey) -> PreferenceObject? {
        get {
            return self.object(forKey: key)
        }
        set {
            if newValue == nil {
                removeObject(forKey: key)
            } else {
                set(newValue, forKey: key)
            }
        }
    }

    public func set(_ value: Int, forKey key: PreferenceKey) {
        self.set(value as PreferenceObject?, forKey: key)
    }
    public func set(_ value: Float, forKey key: PreferenceKey) {
        self.set(value as PreferenceObject?, forKey: key)
    }
    public func set(_ value: Double, forKey key: PreferenceKey) {
        self.set(value as PreferenceObject?, forKey: key)
    }
    public func set(_ value: Bool, forKey key: PreferenceKey) {
        self.set(value as PreferenceObject?, forKey: key)
    }

    public func set(_ url: URL?, forKey key: PreferenceKey) {
        self.set(url as PreferenceObject?, forKey: key)
    }

    public func set(dictionary: PreferencesDictionary) {
        for (key, value) in dictionary {
            self.set(value, forKey: key )
        }
    }

    public func set(objects: [PreferenceObject], forKeys keys: [PreferenceKey]) {
        for keyIndex in 0 ..< keys.count {
            self.set(objects[keyIndex], forKey: keys [keyIndex])
        }
    }

    public func clearAll() {
        for (key, _) in self.dictionary() {
            self.removeObject(forKey: key)
        }
    }

}
