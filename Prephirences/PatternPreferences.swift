//
//  PatternPreferences.swift
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

//MARK: composite pattern
public class CompositePreferences: PreferencesType , ArrayLiteralConvertible {
    
    var array: [PreferencesType] = []
    
    // MARK: singleton
    static let sharedInstance = CompositePreferences([]) // TODO make it lazy
    
    // MARK: init
    public init(_ array: [PreferencesType]){
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
    public subscript(key: String) -> AnyObject? {
        get {
            // first return win
            for prefs in array {
                if let value: AnyObject = prefs.objectForKey(key){
                    return value
                }
            }
            return nil
        }
    }
    
    public func objectForKey(key: String) -> AnyObject? {
        return self[key]
    }

    public func hasObjectForKey(key: String) -> Bool {
        return self[key] != nil
    }
    
    public func stringForKey(key: String) -> String? {
        return self[key] as? String
    }
    public func arrayForKey(key: String) -> [AnyObject]? {
        return self[key] as? [AnyObject]
    }
    public func dictionaryForKey(key: String) -> [String : AnyObject]? {
        return self[key] as? [String: AnyObject]
    }
    public func dataForKey(key: String) -> NSData? {
        return self[key] as? NSData
    }
    public func stringArrayForKey(key: String) -> [String]? {
        return self.arrayForKey(key) as? [String]
    }
    public func integerForKey(key: String) -> Int {
        return self[key] as? Int ?? 0
    }
    public func floatForKey(key: String) -> Float {
        return self[key] as? Float ?? 0
    }
    public func doubleForKey(key: String) -> Double {
        return self[key] as? Double ?? 0
    }
    public func boolForKey(key: String) -> Bool {
        if let b = self[key] as? Bool {
            return b
        }
        return false
    }
    public func URLForKey(key: String) -> NSURL? {
        return self[key] as? NSURL
    }
    
    public func dictionary() -> [String : AnyObject] {
        var dico = [String : AnyObject]()
        for prefs in array.reverse() {
            dico += prefs.dictionary()
        }
        return dico
    }
}

public class MutableCompositePreferences: CompositePreferences, MutablePreferencesType {
    
    public var affectOnlyFirstMutable: Bool

    public override convenience init(_ array: [PreferencesType]){
        self.init(array, affectOnlyFirstMutable: true)
    }
    
    public init(_ array: [PreferencesType], affectOnlyFirstMutable: Bool){
        self.affectOnlyFirstMutable = affectOnlyFirstMutable
        super.init(array)
    }
    
    override public subscript(key: String) -> AnyObject? {
        get {
            // first return win
            for prefs in array {
                if let value: AnyObject = prefs.objectForKey(key){
                    return value
                }
            }
            return nil
        }
        set {
            for prefs in array {
                if let mutablePrefs = prefs as? MutablePreferencesType {
                    mutablePrefs.setObject(newValue, forKey: key)
                    if affectOnlyFirstMutable {
                        break
                    }
                }
            }
        }
    }
    
    public func setObject(value: AnyObject?, forKey key: String) {
        self[key] = value
    }
    public func removeObjectForKey(key: String) {
        self[key] = nil
    }
    public func setInteger(value: Int, forKey key: String){
        self[key] = value
    }
    public func setFloat(value: Float, forKey key: String){
        self[key] = value
    }
    public func setDouble(value: Double, forKey key: String) {
        setObject(NSNumber(double: value), forKey: key)
    }
    public func setBool(value: Bool, forKey key: String) {
        self[key] = value
    }
    public func setURL(url: NSURL?, forKey key: String) {
        self[key] = url
    }
    
    public func setObjectsForKeysWithDictionary(dictionary: [String : AnyObject]){
        for prefs in array {
            if let mutablePrefs = prefs as? MutablePreferencesType {
                mutablePrefs.setObjectsForKeysWithDictionary(dictionary)
                if affectOnlyFirstMutable {
                    break
                }
            }
        }
    }
    public  func clearAll() {
        for prefs in array {
            if let mutablePrefs = prefs as? MutablePreferencesType {
                mutablePrefs.clearAll()
            }
        }
    }
    
}

//MARK: proxy pattern
public class ProxyPreferences {
    private let proxiable: PreferencesType
    private let parentKey: String
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
    
    private func computeKey(key: String) -> String {
        return self.parentKey + (self.separator ?? "") + key
    }
    
    private func hasRecursion() -> Bool {
        return self.separator != nil
    }
    
    public subscript(key: String) -> AnyObject? {
        get {
            let finalKey = computeKey(key)
            if let value: AnyObject = self.proxiable.objectForKey(finalKey) {
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
    public func objectForKey(key: String) -> AnyObject? {
        return self.proxiable.objectForKey(key)
    }
    public func hasObjectForKey(key: String) -> Bool {
        return self.proxiable.hasObjectForKey(key)
    }
    public func stringForKey(key: String) -> String? {
        return self.proxiable.stringForKey(key)
    }
    public func arrayForKey(key: String) -> [AnyObject]? {
        return self.proxiable.arrayForKey(key)
    }
    public func dictionaryForKey(key: String) -> [String : AnyObject]? {
        return self.proxiable.dictionaryForKey(key)
    }
    public func dataForKey(key: String) -> NSData? {
        return self.proxiable.dataForKey(key)
    }
    public func stringArrayForKey(key: String) -> [String]? {
        return self.proxiable.stringArrayForKey(key)
    }
    public func integerForKey(key: String) -> Int {
        return self.proxiable.integerForKey(key)
    }
    public func floatForKey(key: String) -> Float {
        return self.proxiable.floatForKey(key)
    }
    public func doubleForKey(key: String) -> Double {
        return self.proxiable.doubleForKey(key)
    }
    public func boolForKey(key: String) -> Bool {
        return self.proxiable.boolForKey(key)
    }
    public func URLForKey(key: String) -> NSURL? {
        return self.proxiable.URLForKey(key)
    }
    public func unarchiveObjectForKey(key: String) -> AnyObject? {
        return self.proxiable.unarchiveObjectForKey(key)
    }
    public func dictionary() -> [String : AnyObject] {
        return self.proxiable.dictionary()
    }
}

public class MutableProxyPreferences: ProxyPreferences {
    
    private var mutable: MutablePreferencesType {
        return self.proxiable as! MutablePreferencesType
    }
    
    public init(preferences proxiable: MutablePreferencesType, key parentKey: String, separator: String) {
        super.init(preferences: proxiable, key: parentKey, separator: separator)
    }
    
    override public subscript(key: String) -> AnyObject? {
        get {
            let finalKey = computeKey(key)
            if let value: AnyObject = self.proxiable.objectForKey(finalKey) {
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
                self.mutable.removeObjectForKey(finalKey)
            } else {
                self.mutable.setObject(newValue, forKey: finalKey)
            }
        }
    }
    
}

extension MutableProxyPreferences: MutablePreferencesType {
    public func setObject(value: AnyObject?, forKey key: String){
       self.mutable.setObject(value, forKey: key)
    }
    public func removeObjectForKey(key: String){
        self.mutable.removeObjectForKey(key)
    }
    public func setInteger(value: Int, forKey key: String){
         self.mutable.setInteger(value, forKey: key)
    }
    public func setFloat(value: Float, forKey key: String){
        self.mutable.setFloat(value, forKey: key)
    }
    public func setDouble(value: Double, forKey key: String){
        self.mutable.setDouble(value, forKey: key)
    }
    public func setBool(value: Bool, forKey key: String){
        self.mutable.setBool(value, forKey: key)
    }
    public func setURL(url: NSURL?, forKey key: String){
        self.mutable.setURL(url, forKey: key)
    }
    public func setObjectToArchive(value: AnyObject?, forKey key: String) {
         self.mutable.setObjectToArchive(value, forKey: key)
    }
    public func clearAll(){
        self.mutable.clearAll()
    }
    public func setObjectsForKeysWithDictionary(registrationDictionary: [String : AnyObject]){
        self.mutable.setObjectsForKeysWithDictionary(registrationDictionary)
    }
}

// MARK: adapter generic
// Allow to implement 'dictionary' using the new 'keys'
// Subclasses must implement objectForKey & keys
public protocol PreferencesAdapter: PreferencesType {

    func keys() -> [String]

}

extension PreferencesAdapter {

    public func dictionary() -> [String : AnyObject] {
        var dico:Dictionary<String, AnyObject> = [:]
        for name in self.keys() {
            if let value: AnyObject = self.objectForKey(name) {
                dico[name] = value
            }
        }
        return dico
    }
}


// MARK : KVC
// object must informal protocol NSKeyValueCoding
public class KVCPreferences: PreferencesAdapter {
    private let object: NSObject
    
    public init(_ object: NSObject) {
        self.object = object
    }
    
    public func objectForKey(key: String) -> AnyObject? {
        return self.object.valueForKey(key)
    }
    
    public func keys() -> [String] {
        var names: [String] = []
        var count: UInt32 = 0
        // FIXME: not recursive?
        let properties = class_copyPropertyList(self.object.classForCoder, &count)
        for i in 0 ..< Int(count) {
            let property: objc_property_t = properties[i]
            let name: String = String.fromCString(property_getName(property))!
            names.append(name)
        }
        free(properties)
        return names
    }
    
}

public class MutableKVCPreferences: KVCPreferences {
    
    public override init(_ object: NSObject) {
        super.init(object)
    }
    
    public subscript(key: String) -> AnyObject? {
        get {
             return self.objectForKey(key)
        }
        set {
            self.setObject(newValue, forKey: key)
        }
    }
    
}

extension MutableKVCPreferences: MutablePreferencesType {
    public func setObject(value: AnyObject?, forKey key: String){
        if (self.object.respondsToSelector(NSSelectorFromString(key))) {
            self.object.setValue(value, forKey: key)
        }
    }
    public func removeObjectForKey(key: String){
        if (self.object.respondsToSelector(NSSelectorFromString(key))) {
            self.object.setValue(nil, forKey: key)
        }
    }
    public func setInteger(value: Int, forKey key: String){
        self.setObject(NSNumber(integer: value), forKey: key)
    }
    public func setFloat(value: Float, forKey key: String){
        self.setObject(NSNumber(float: value), forKey: key)
    }
    public func setDouble(value: Double, forKey key: String){
        self.setObject(NSNumber(double: value), forKey: key)
    }
    public func setBool(value: Bool, forKey key: String){
        self.setObject(NSNumber(bool: value), forKey: key)
    }
    public func clearAll(){
       // not implemented, maybe add protocol to set defaults attributes values
    }

}

// MARK: - Collection
// Adapter for collection to conform to PreferencesType
// using two closure to get key and value from an object
public class CollectionPreferencesAdapter<C: CollectionType> {

    let collection: C
    let mapKey: C.Generator.Element -> String
    let mapValue: C.Generator.Element -> AnyObject

    public init(collection: C,
        mapKey: C.Generator.Element -> String,
        mapValue: C.Generator.Element -> AnyObject
        ) {
            self.collection = collection
            self.mapKey = mapKey
            self.mapValue = mapValue
    }

}

extension CollectionPreferencesAdapter: PreferencesType {

    public func objectForKey(key: String) -> AnyObject? {
        if let object = collection.find({ mapKey($0) == key }){
            return mapValue(object)
        }
        return nil
    }

    public func dictionary() -> [String : AnyObject] {
        return collection.dictionary{ ( mapKey($0), mapValue($0) ) }
    }

}


extension CollectionType {

    func mapFilterNil<T>(@noescape transform: (Self.Generator.Element) -> T?) -> [T] {
        return self.map(transform).filter{ $0 != nil }.map{ $0! }
    }

    func dictionary<K, V>(@noescape transform: (Self.Generator.Element) throws -> (key: K, value: V)?) rethrows -> Dictionary<K, V> {
        var dict: Dictionary<K, V> = [:]
        for e in self {
            if let (key, value) = try transform(e)
            {
                dict[key] = value
            }
        }
        return dict
    }

    func find(@noescape predicate: (Self.Generator.Element) throws -> Bool) rethrows -> Self.Generator.Element? {
        return try indexOf(predicate).map({ self[$0] })
    }
}