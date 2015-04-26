//
//  DictionaryPreferences.swift
//  Prephirences
//
//  Created by phimage on 22/04/15.
//  Copyright (c) 2015 phimage. All rights reserved.
//

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

    public init?(filename: String?, ofType ext: String?) {
        if let filePath = NSBundle.mainBundle().pathForResource(filename, ofType: ext) {
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
    public func dictionaryForKey(key: String) -> [NSObject : AnyObject]? {
        return dico[key] as? [String: AnyObject]
    }
    public func dataForKey(key: String) -> NSData? {
        return dico[key] as? NSData
    }
    public func stringArrayForKey(key: String) -> [AnyObject]? {
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
    public func writeToFile(path: String, atomically: Bool) {
        (self.dico as NSDictionary).writeToFile(path, atomically: atomically)
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
        setObject(NSNumber(double: value), forKey: key)
    }
    public func setBool(value: Bool, forKey key: String) {
        dico[key] = value
    }
    public func setURL(url: NSURL, forKey key: String) {
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