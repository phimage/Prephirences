//
//  DictionaryPreferences.swift
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

// MARK: Dictionary Adapter
// Adapt Dictionary to PreferencesType (with adapter pattern)
open class DictionaryPreferences: PreferencesType, Sequence, ExpressibleByDictionaryLiteral {

    internal var dico: PreferencesDictionary

    // MARK: init
    public init(dictionary: PreferencesDictionary) {
        self.dico = dictionary
    }

    public init?(filePath: String) {
        if let d = NSDictionary(contentsOfFile: filePath) as? PreferencesDictionary {
            self.dico = d
        } else {
            self.dico = [:]
            return nil
        }
    }

    public init?(filename: String?, ofType ext: String?, bundle: Bundle = Bundle.main) {
        if let filePath = bundle.path(forResource: filename, ofType: ext) {
            if let d = NSDictionary(contentsOfFile: filePath) as? PreferencesDictionary {
                self.dico = d
            } else {
                self.dico = [:]
                return nil
            }
        } else {
            self.dico = [:]
            return nil
        }
    }

    public init(preferences: PreferencesType) {
        self.dico = preferences.dictionary()
    }

    // MARK: DictionaryLiteralConvertibles
    public typealias Key = PreferenceKey
    public typealias Value = PreferenceObject
    public typealias Element = (Key, Value)

    public required convenience init(dictionaryLiteral elements: Element...) {
        self.init(dictionary: [:])
        for (key, value) in elements {
            dico[key] = value
        }
    }

    // MARK: SequenceType

    open func makeIterator() -> DictionaryIterator<Key, Value> {
        return self.dico.makeIterator()
    }

    public typealias Index = DictionaryIndex<Key, Value>

    open subscript (position: DictionaryIndex<Key, Value>) -> Element {
        get {
            return dico[position]
        }
    }

    open subscript(key: Key?) -> Value? {
        get {
            if key != nil {
                return dico[key!]
            }
            return nil
        }
    }

    // MARK: PreferencesType
    open subscript(key: String) -> PreferenceObject? {
        get {
            return dico[key]
        }
    }

    open func object(forKey key: PreferenceKey) -> PreferenceObject? {
        return dico[key]
    }

    open func hasObject(forKey key: PreferenceKey) -> Bool {
        return dico[key] != nil
    }

    open func string(forKey key: PreferenceKey) -> String? {
        return dico[key] as? String
    }
    open func array(forKey key: PreferenceKey) -> [PreferenceObject]? {
        return dico[key] as? [AnyObject]
    }
    open func dictionary(forKey key: PreferenceKey) -> [String : AnyObject]? {
        return dico[key] as? [String: AnyObject]
    }
    open func data(forKey key: PreferenceKey) -> Data? {
        return dico[key] as? Data
    }
    open func stringArray(forKey key: PreferenceKey) -> [String]? {
        return self.array(forKey: key) as? [String]
    }
    open func integer(forKey key: PreferenceKey) -> Int {
        return dico[key] as? Int ?? 0
    }
    open func float(forKey key: PreferenceKey) -> Float {
        return dico[key] as? Float ?? 0
    }
    open func double(forKey key: PreferenceKey) -> Double {
        return dico[key] as? Double ?? 0
    }
    open func bool(forKey key: PreferenceKey) -> Bool {
        return dico[key] as? Bool ?? false
    }
    open func url(forKey key: PreferenceKey) -> URL? {
        return dico[key] as? URL
    }

    open func dictionary() -> PreferencesDictionary {
        return self.dico
    }

    // MARK: specifics methods
    open func writeToFile(_ path: String, atomically: Bool = true) -> Bool {
        return (self.dico as NSDictionary).write(toFile: path, atomically: atomically)
    }
}

// MARK: - Mutable Dictionary Adapter
open class MutableDictionaryPreferences: DictionaryPreferences, MutablePreferencesType {

    // MARK: MutablePreferencesType
    open override subscript(key: PreferenceKey) -> PreferenceObject? {
        get {
            return dico[key]
        }
        set {
            dico[key] = newValue
        }
    }

    open func set(_ value: PreferenceObject?, forKey key: PreferenceKey) {
        dico[key] = value
    }
    open func removeObject(forKey key: PreferenceKey) {
        dico[key] = nil
    }

    open func set(_ value: Int, forKey key: PreferenceKey) {
        dico[key] = value
    }
    open func set(_ value: Float, forKey key: PreferenceKey) {
        dico[key] = value
    }
    open func set(_ value: Double, forKey key: PreferenceKey) {
        dico[key] = value
    }
    open func set(_ value: Bool, forKey key: PreferenceKey) {
        dico[key] = value
    }
    open func set(_ url: URL?, forKey key: PreferenceKey) {
        dico[key] = url
    }

    open func set(dictionary: PreferencesDictionary) {
         dico += dictionary
    }

    open func clearAll() {
        dico.removeAll()
    }

}

// MARK: - private
// dictionary append
internal func +=<K, V> (left: inout [K : V], right: [K : V]) { for (k, v) in right { left[k] = v } }

// MARK: - Buffered preferences
open class BufferPreferences: MutableDictionaryPreferences {
    var buffered: MutablePreferencesType

    public init(_ buffered: MutablePreferencesType) {
        self.buffered = buffered
        super.init(dictionary: buffered.dictionary())
    }

    public required convenience init(dictionaryLiteral elements: (Key, Value)...) {
        fatalError("init(dictionaryLiteral:) has not been implemented")
    }

    // MARK: specifics methods
    func commit() {
        buffered.set(dictionary: self.dictionary())
    }

    func rollback() {
        self.dico = buffered.dictionary()
    }
}
