//
//  DictionaryPreferences.swift
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

// MARK: Dictionary Adapter
// Adapt Dictionary to PreferencesType (with adapter pattern)
public class DictionaryPreferences: PreferencesType, SequenceType, DictionaryLiteralConvertible {

    internal var dico : Dictionary<String,AnyObject>

    // MARK: init
    public init(dictionary: Dictionary<String,AnyObject>) {
        self.dico = dictionary
    }
    
    public init?(filePath: String) {
        if let d = NSDictionary(contentsOfFile: filePath) as? Dictionary<String,AnyObject> {
            self.dico = d
        }
        else {
            self.dico = [:]
            return nil
        }
    }

    public init?(filename: String?, ofType ext: String?, bundle: NSBundle = NSBundle.mainBundle()) {
        if let filePath = bundle.pathForResource(filename, ofType: ext) {
            if let d = NSDictionary(contentsOfFile: filePath) as? Dictionary<String,AnyObject> {
                self.dico = d
            }
            else {
                self.dico = [:]
                return nil
            }
        }
        else {
            self.dico = [:]
            return nil
        }
    }

    public init(preferences: PreferencesType) {
        self.dico = preferences.dictionary()
    }
    
    // MARK: DictionaryLiteralConvertibles
    public typealias Key = String
    public typealias Value = AnyObject
    public typealias Element = (Key, Value)

    public required convenience init(dictionaryLiteral elements: Element...) {
        self.init(dictionary: [:])
        for (key, value) in elements {
            dico[key] = value
        }
    }
    
    // MARK: SequenceType

    public func generate() -> DictionaryGenerator<Key, Value> {
        return self.dico.generate()
    }
    
    public typealias Index = DictionaryIndex<Key, Value>
    
    public subscript (position: DictionaryIndex<Key, Value>) -> Element {
        get {
            return dico[position]
        }
    }

    public subscript(key : Key?) -> Value? {
        get {
            if key != nil {
                return dico[key!]
            }
            return nil
        }
    }
    
    // MARK: PreferencesType
    public subscript(key: String) -> AnyObject? {
        get {
            return dico[key]
        }
    }
    
    public func objectForKey(key: String) -> AnyObject? {
        return dico[key]
    }
    
    public func hasObjectForKey(key: String) -> Bool {
        return dico[key] != nil
    }
    
    public func stringForKey(key: String) -> String? {
        return dico[key] as? String
    }
    public func arrayForKey(key: String) -> [AnyObject]? {
        return dico[key] as? [AnyObject]
    }
    public func dictionaryForKey(key: String) -> [String : AnyObject]? {
        return dico[key] as? [String: AnyObject]
    }
    public func dataForKey(key: String) -> NSData? {
        return dico[key] as? NSData
    }
    public func stringArrayForKey(key: String) -> [String]? {
        return self.arrayForKey(key) as? [String]
    }
    public func integerForKey(key: String) -> Int {
        return dico[key] as? Int ?? 0
    }
    public func floatForKey(key: String) -> Float {
        return dico[key] as? Float ?? 0
    }
    public func doubleForKey(key: String) -> Double {
        return dico[key] as? Double ?? 0
    }
    public func boolForKey(key: String) -> Bool {
        return dico[key] as? Bool ?? false
    }
    public func URLForKey(key: String) -> NSURL? {
        return dico[key] as? NSURL
    }

    public func dictionary() -> [String : AnyObject] {
        return self.dico
    }
    
    // MARK: specifics methods
    public func writeToFile(path: String, atomically: Bool = true) -> Bool {
        return (self.dico as NSDictionary).writeToFile(path, atomically: atomically)
    }
}

// MARK: - Mutable Dictionary Adapter
public class MutableDictionaryPreferences: DictionaryPreferences, MutablePreferencesType {
    
    // MARK: MutablePreferencesType
    public override subscript(key: String) -> AnyObject? {
        get {
            return dico[key]
        }
        set {
            dico[key] = newValue
        }
    }
    
    public func setObject(value: AnyObject?, forKey key: String) {
        dico[key] = value
    }
    public func removeObjectForKey(key: String) {
        dico[key] = nil
    }
    
    public func setInteger(value: Int, forKey key: String){
        dico[key] = value
    }
    public func setFloat(value: Float, forKey key: String){
        dico[key] = value
    }
    public func setDouble(value: Double, forKey key: String) {
        dico[key] = value
    }
    public func setBool(value: Bool, forKey key: String) {
        dico[key] = value
    }
    public func setURL(url: NSURL?, forKey key: String) {
        dico[key] = url
    }
    
    public func setObjectsForKeysWithDictionary(dictionary: [String:AnyObject]) {
         dico += dictionary
    }
    
    public func clearAll() {
        dico.removeAll()
    }
    
}

// MARK: - Buffered preferences
public class BufferPreferences: MutableDictionaryPreferences {
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
        buffered.setObjectsForKeysWithDictionary(self.dictionary())
    }
    
    func rollback() {
        self.dico = buffered.dictionary()
    }
}