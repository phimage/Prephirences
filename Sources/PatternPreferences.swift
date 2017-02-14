//
//  PatternPreferences.swift
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

// MARK: composite pattern
open class CompositePreferences: PreferencesType, ExpressibleByArrayLiteral {

    var array: [PreferencesType] = []

    // MARK: singleton
    static let sharedInstance = CompositePreferences([])

    // MARK: init
    public init(_ array: [PreferencesType]) {
        self.array = array
    }

    // MARK: ArrayLiteralConvertible
    public typealias Element = PreferencesType

    public convenience required init(arrayLiteral elements: Element...) {
        self.init([])
        for element in elements {
            self.array.append(element)
        }
    }

    // MARK: PreferencesType
    open subscript(key: PreferenceKey) -> PreferenceObject? {
        get {
            // first return win
            for prefs in array {
                if let value = prefs.object(forKey: key) {
                    return value
                }
            }
            return nil
        }
    }

    open func object(forKey key: PreferenceKey) -> PreferenceObject? {
        return self[key]
    }

    open func hasObject(forKey key: PreferenceKey) -> Bool {
        return self[key] != nil
    }

    open func string(forKey key: PreferenceKey) -> String? {
        return self[key] as? String
    }
    open func array(forKey key: PreferenceKey) -> [PreferenceObject]? {
        return self[key] as? [AnyObject]
    }
    open func dictionary(forKey key: PreferenceKey) -> [String : AnyObject]? {
        return self[key] as? [String: AnyObject]
    }
    open func data(forKey key: PreferenceKey) -> Data? {
        return self[key] as? Data
    }
    open func stringArray(forKey key: PreferenceKey) -> [String]? {
        return self.array(forKey: key) as? [String]
    }
    open func integer(forKey key: PreferenceKey) -> Int {
        return self[key] as? Int ?? 0
    }
    open func float(forKey key: PreferenceKey) -> Float {
        return self[key] as? Float ?? 0
    }
    open func double(forKey key: PreferenceKey) -> Double {
        return self[key] as? Double ?? 0
    }
    open func bool(forKey key: PreferenceKey) -> Bool {
        if let b = self[key] as? Bool {
            return b
        }
        return false
    }
    open func url(forKey key: PreferenceKey) -> URL? {
        return self[key] as? URL
    }

    open func dictionary() -> PreferencesDictionary {
        var dico = PreferencesDictionary()
        for prefs in array.reversed() {
            dico += prefs.dictionary()
        }
        return dico
    }
}

open class MutableCompositePreferences: CompositePreferences, MutablePreferencesType {

    open var affectOnlyFirstMutable: Bool

    public override convenience init(_ array: [PreferencesType]) {
        self.init(array, affectOnlyFirstMutable: true)
    }

    public init(_ array: [PreferencesType], affectOnlyFirstMutable: Bool) {
        self.affectOnlyFirstMutable = affectOnlyFirstMutable
        super.init(array)
    }

    override open subscript(key: PreferenceKey) -> PreferenceObject? {
        get {
            // first return win
            for prefs in array {
                if let value = prefs.object(forKey: key) {
                    return value
                }
            }
            return nil
        }
        set {
            for prefs in array {
                if let mutablePrefs = prefs as? MutablePreferencesType {
                    mutablePrefs.set(newValue, forKey: key)
                    if affectOnlyFirstMutable {
                        break
                    }
                }
            }
        }
    }

    open func set(_ value: PreferenceObject?, forKey key: PreferenceKey) {
        self[key] = value
    }
    open func removeObject(forKey key: PreferenceKey) {
        self[key] = nil
    }
    open func set(_ value: Int, forKey key: PreferenceKey) {
        self[key] = value
    }
    open func set(_ value: Float, forKey key: PreferenceKey) {
        self[key] = value
    }
    open func set(_ value: Double, forKey key: PreferenceKey) {
        self[key] = value
    }
    open func set(_ value: Bool, forKey key: PreferenceKey) {
        self[key] = value
    }
    open func set(_ url: URL?, forKey key: PreferenceKey) {
        self[key] = url
    }

    open func set(dictionary: PreferencesDictionary) {
        for prefs in array {
            if let mutablePrefs = prefs as? MutablePreferencesType {
                mutablePrefs.set(dictionary: dictionary)
                if affectOnlyFirstMutable {
                    break
                }
            }
        }
    }
    open  func clearAll() {
        for prefs in array {
            if let mutablePrefs = prefs as? MutablePreferencesType {
                mutablePrefs.clearAll()
            }
        }
    }

}

// MARK: proxy pattern
open class ProxyPreferences {
    fileprivate let proxiable: PreferencesType
    fileprivate let parentKey: String
    var separator: String?

    public convenience init(preferences proxiable: PreferencesType) {
        self.init(preferences: proxiable, key: "")
    }

    public convenience init(preferences proxiable: PreferencesType, key parentKey: String) {
        self.init(preferences: proxiable, key: parentKey, separator: nil)
    }

    public init(preferences proxiable: PreferencesType, key parentKey: String, separator: String?) {
        self.proxiable = proxiable
        self.parentKey = parentKey
        self.separator = separator
    }

    fileprivate func computeKey(_ key: String) -> String {
        return self.parentKey + (self.separator ?? "") + key
    }

    fileprivate func hasRecursion() -> Bool {
        return self.separator != nil
    }

    open subscript(key: String) -> PreferenceObject? {
        get {
            let finalKey = computeKey(key)
            if let value = self.proxiable.object(forKey: finalKey) {
                return value
            }
            if hasRecursion() {
                return ProxyPreferences(preferences: self.proxiable, key: finalKey, separator: self.separator)
            }
            return nil
        }
    }

}

extension ProxyPreferences: PreferencesType {

    public func object(forKey key: PreferenceKey) -> PreferenceObject? {
        return self.proxiable.object(forKey: key)
    }
    public func hasObject(forKey key: PreferenceKey) -> Bool {
        return self.proxiable.hasObject(forKey: key)
    }
    public func string(forKey key: PreferenceKey) -> String? {
        return self.proxiable.string(forKey: key)
    }
    public func array(forKey key: PreferenceKey) -> [PreferenceObject]? {
        return self.proxiable.array(forKey: key)
    }
    public func dictionary(forKey key: PreferenceKey) -> PreferencesDictionary? {
        return self.proxiable.dictionary(forKey: key)
    }
    public func data(forKey key: PreferenceKey) -> Data? {
        return self.proxiable.data(forKey: key)
    }
    public func stringArray(forKey key: PreferenceKey) -> [String]? {
        return self.proxiable.stringArray(forKey: key)
    }
    public func integer(forKey key: PreferenceKey) -> Int {
        return self.proxiable.integer(forKey: key)
    }
    public func float(forKey key: PreferenceKey) -> Float {
        return self.proxiable.float(forKey: key)
    }
    public func double(forKey key: PreferenceKey) -> Double {
        return self.proxiable.double(forKey: key)
    }
    public func bool(forKey key: PreferenceKey) -> Bool {
        return self.proxiable.bool(forKey: key)
    }
    public func url(forKey key: PreferenceKey) -> URL? {
        return self.proxiable.url(forKey: key)
    }
    public func unarchiveObject(forKey key: PreferenceKey) -> PreferenceObject? {
        return self.proxiable.unarchiveObject(forKey: key)
    }
    public func dictionary() -> PreferencesDictionary {
        return self.proxiable.dictionary()
    }
}

open class MutableProxyPreferences: ProxyPreferences {

    fileprivate var mutable: MutablePreferencesType {
        // swiftlint:disable:next force_cast
        return self.proxiable as! MutablePreferencesType
    }

    public init(preferences proxiable: MutablePreferencesType, key parentKey: PreferenceKey, separator: String) {
        super.init(preferences: proxiable, key: parentKey, separator: separator)
    }

    override open subscript(key: PreferenceKey) -> PreferenceObject? {
        get {
            let finalKey = computeKey(key)
            if let value = self.proxiable.object(forKey: finalKey) {
                return value
            }
            if hasRecursion() {
                return ProxyPreferences(preferences: self.proxiable, key: finalKey, separator: self.separator)
            }
            return nil
        }
        set {
            let finalKey = computeKey(key)
            if newValue == nil {
                self.mutable.removeObject(forKey: finalKey)
            } else {
                self.mutable.set(newValue, forKey: finalKey)
            }
        }
    }

}

extension MutableProxyPreferences: MutablePreferencesType {

    public func set(_ value: PreferenceObject?, forKey key: PreferenceKey) {
       self.mutable.set(value, forKey: key)
    }
    public func removeObject(forKey key: PreferenceKey) {
        self.mutable.removeObject(forKey: key)
    }
    public func set(_ value: Int, forKey key: PreferenceKey) {
         self.mutable.set(value, forKey: key)
    }
    public func set(_ value: Float, forKey key: PreferenceKey) {
        self.mutable.set(value, forKey: key)
    }
    public func set(_ value: Double, forKey key: PreferenceKey) {
        self.mutable.set(value, forKey: key)
    }
    public func set(_ value: Bool, forKey key: PreferenceKey) {
        self.mutable.set(value, forKey: key)
    }
    public func set(_ url: URL?, forKey key: PreferenceKey) {
        self.mutable.set(url, forKey: key)
    }
    public func set(objectToArchive value: PreferenceObject?, forKey key: PreferenceKey) {
        self.mutable.set(objectToArchive: value, forKey: key)
    }
    public func clearAll() {
        self.mutable.clearAll()
    }
    public func set(dictionary registrationDictionary: PreferencesDictionary) {
        self.mutable.set(dictionary: registrationDictionary)
    }
}

extension PreferencesType {

    public func immutableProxy() -> PreferencesType {
        return ProxyPreferences(preferences: self)
    }

}

// MARK: adapter generic
// Allow to implement 'dictionary' using the new 'keys'
// Subclasses must implement objectForKey & keys
public protocol PreferencesAdapter: PreferencesType {

    func keys() -> [String]

}

extension PreferencesAdapter {

    public func dictionary() -> PreferencesDictionary {
        var dico: PreferencesDictionary = [:]
        for name in self.keys() {
            if let value = self.object(forKey: name) {
                dico[name] = value
            }
        }
        return dico
    }
}

// MARK: KVC
// object must informal protocol NSKeyValueCoding
open class KVCPreferences: PreferencesAdapter {
    fileprivate let object: NSObject

    public init(_ object: NSObject) {
        self.object = object
    }

    open func object(forKey key: PreferenceKey) -> PreferenceObject? {
        return self.object.value(forKey: key)
    }

    open func keys() -> [String] {
        var names: [String] = []
        var count: UInt32 = 0
        // FIXME: not recursive?
        let properties = class_copyPropertyList(self.object.classForCoder, &count)
        for i in 0 ..< Int(count) {
            let property: objc_property_t = properties![i]!
            let name: String = String(cString: property_getName(property))
            names.append(name)
        }
        free(properties)
        return names
    }

}

open class MutableKVCPreferences: KVCPreferences {

    public override init(_ object: NSObject) {
        super.init(object)
    }

    open subscript(key: PreferenceKey) -> PreferenceObject? {
        get {
             return self.object(forKey: key)
        }
        set {
            self.set(newValue, forKey: key)
        }
    }

}

extension MutableKVCPreferences: MutablePreferencesType {
    public func set(_ value: PreferenceObject?, forKey key: PreferenceKey) {
        if self.object.responds(to: NSSelectorFromString(key)) {
            self.object.setValue(value, forKey: key)
        }
    }
    public func removeObject(forKey key: PreferenceKey) {
        if self.object.responds(to: NSSelectorFromString(key)) {
            self.object.setValue(nil, forKey: key)
        }
    }
    public func set(_ value: Int, forKey key: PreferenceKey) {
        self.set(NSNumber(value: value), forKey: key)
    }
    public func set(_ value: Float, forKey key: PreferenceKey) {
        self.set(NSNumber(value: value), forKey: key)
    }
    public func set(_ value: Double, forKey key: PreferenceKey) {
        self.set(NSNumber(value: value), forKey: key)
    }
    public func set(_ value: Bool, forKey key: PreferenceKey) {
        self.set(NSNumber(value: value), forKey: key)
    }
    public func clearAll() {
       // not implemented, maybe add protocol to set defaults attributes values
    }

}

// MARK: - Collection
// Adapter for collection to conform to PreferencesType
// using two closure to get key and value from an object
open class CollectionPreferencesAdapter<C: Collection> {

    let collection: C
    public typealias MapPreferenceKey = (C.Iterator.Element) -> PreferenceKey
    public typealias MapPreferenceObject = (C.Iterator.Element) -> PreferenceObject

    let mapKey: MapPreferenceKey
    let mapValue: MapPreferenceObject

    public init(collection: C, mapKey: @escaping MapPreferenceKey, mapValue: @escaping MapPreferenceObject) {
        self.collection = collection
        self.mapKey = mapKey
        self.mapValue = mapValue
    }

}

extension CollectionPreferencesAdapter: PreferencesType {

    public func object(forKey key: PreferenceKey) -> PreferenceObject? {
        if let object = collection.find({ mapKey($0) == key }) {
            return mapValue(object)
        }
        return nil
    }

    public func dictionary() -> PreferencesDictionary {
        return collection.dictionary { ( mapKey($0), mapValue($0) ) }
    }

}

extension Collection {

    func mapFilterNil<T>(_ transform: (Self.Iterator.Element) -> T?) -> [T] {
        return self.map(transform).filter { $0 != nil }.map { $0! }
    }

    func dictionary<K, V>(_ transform: (Self.Iterator.Element) throws -> (key: K, value: V)?) rethrows -> [K: V] {
        var dict: [K: V] = [:]
        for e in self {
            if let (key, value) = try transform(e) {
                dict[key] = value
            }
        }
        return dict
    }

    func find(_ predicate: (Self.Iterator.Element) throws -> Bool) rethrows -> Self.Iterator.Element? {
        return try index(where: predicate).map({ self[$0] })
    }

}
