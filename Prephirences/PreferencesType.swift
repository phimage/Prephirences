//
//  PreferencesType.swift
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

public typealias PreferenceObject = AnyObject
public typealias PreferenceKey = String

// MARK: - Preferences
public protocol PreferencesType {

    func objectForKey(key: PreferenceKey) -> PreferenceObject?
    func dictionary() -> [PreferenceKey : PreferenceObject]

    // MARK: Optional methods
    subscript(key: PreferenceKey) -> PreferenceObject? {get}
    func hasObjectForKey(key: PreferenceKey) -> Bool
    
    
    func stringForKey(key: PreferenceKey) -> String?
    func arrayForKey(key: PreferenceKey) -> [PreferenceObject]?
    func dictionaryForKey(key: PreferenceKey) -> [PreferenceKey : PreferenceObject]?
    func stringArrayForKey(key: PreferenceKey) -> [String]?
    func integerForKey(key: PreferenceKey) -> Int
    func floatForKey(key: PreferenceKey) -> Float
    func doubleForKey(key: PreferenceKey) -> Double
    func boolForKey(key: PreferenceKey) -> Bool

    func dataForKey(key: PreferenceKey) -> NSData?
    func URLForKey(key: PreferenceKey) -> NSURL?

    func unarchiveObjectForKey(key: PreferenceKey) -> PreferenceObject?
    func preferenceForKey<T>(key: PreferenceKey) -> Preference<T>

}

// MARK: - Mutable Preferences
public protocol MutablePreferencesType: PreferencesType {

    func setObject(value: PreferenceObject?, forKey key: PreferenceKey)
    func removeObjectForKey(key: String)

    // MARK: Optional methods

    subscript(key: String) -> PreferenceObject? {get set}

    func setInteger(value: Int, forKey key: PreferenceKey)
    func setFloat(value: Float, forKey key: PreferenceKey)
    func setDouble(value: Double, forKey key: PreferenceKey)
    func setBool(value: Bool, forKey key: PreferenceKey)
    func setURL(url: NSURL?, forKey key: PreferenceKey)

    func setObjectToArchive(value: PreferenceObject?, forKey key: String)
    
    func clearAll()
    func setObjectsForKeysWithDictionary(dictionary: [PreferenceKey : PreferenceObject])

    func preferenceForKey<T>(key: PreferenceKey) -> MutablePreference<T>
    
    func immutableProxy() -> PreferencesType
}

// MARK: - Default implementations for optional methods
public extension PreferencesType {

    subscript(key: PreferenceKey) -> AnyObject? {
        return objectForKey(key)
    }
    public func hasObjectForKey(key: PreferenceKey) -> Bool {
        return self.objectForKey(key) != nil
    }

    public func stringForKey(key: PreferenceKey) -> String? {
        return self.objectForKey(key) as? String
    }
    public func arrayForKey(key: PreferenceKey) -> [AnyObject]? {
        return self.objectForKey(key) as? [AnyObject]
    }
    public func dictionaryForKey(key: PreferenceKey) -> [String : AnyObject]? {
        return self.objectForKey(key) as? [String : AnyObject]
    }
    public func dataForKey(key: PreferenceKey) -> NSData? {
        return self.objectForKey(key) as? NSData
    }
    public func stringArrayForKey(key: PreferenceKey) -> [String]? {
        return self.objectForKey(key) as? [String]
    }
    public func integerForKey(key: PreferenceKey) -> Int {
        return self.objectForKey(key) as? Int ?? 0
    }
    public func floatForKey(key: PreferenceKey) -> Float {
        return self.objectForKey(key) as? Float ?? 0
    }
    public func doubleForKey(key: PreferenceKey) -> Double {
        return self.objectForKey(key) as? Double ?? 0
    }
    public func boolForKey(key: PreferenceKey) -> Bool {
        return self.objectForKey(key) as? Bool ?? false
    }
    public func URLForKey(key: PreferenceKey) -> NSURL? {
        return self.objectForKey(key) as? NSURL
    }
    

    public func unarchiveObjectForKey(key: PreferenceKey) -> AnyObject? {
        return Prephirences.unarchiveObject(self, forKey: key)
    }
    public func preferenceForKey<T>(key: PreferenceKey) -> Preference<T> {
        return Preference<T>(preferences: self, key: key)
    }

}

public extension MutablePreferencesType {

    public subscript(key: PreferenceKey) -> AnyObject? {
        get {
            return self.objectForKey(key)
        }
        set {
            if newValue == nil {
                removeObjectForKey(key)
            } else {
                setObject(newValue, forKey: key)
            }
        }
    }

    func setInteger(value: Int, forKey key: PreferenceKey) {
        self.setObject(value, forKey: key)
    }
    func setFloat(value: Float, forKey key: PreferenceKey) {
        self.setObject(value, forKey: key)
    }
    func setDouble(value: Double, forKey key: PreferenceKey) {
        self.setObject(value, forKey: key)
    }
    func setBool(value: Bool, forKey key: PreferenceKey) {
        self.setObject(value, forKey: key)
    }

    public func preferenceForKey<T>(key: PreferenceKey) -> MutablePreference<T> {
        return MutablePreference<T>(preferences: self, key: key)
    }
    
    public func immutableProxy() -> PreferencesType {
        return ProxyPreferences(preferences: self)
    }
    
    public func setObjectsForKeysWithDictionary(dictionary: [PreferenceKey : AnyObject]){
        for (key,value) in dictionary {
            self.setObject(value, forKey: key )
        }
    }

    public func setObjects(objects: [AnyObject], forKeys keys: [PreferenceKey]) {
        for keyIndex in 0 ..< keys.count {
            self.setObject(objects[keyIndex], forKey: keys [keyIndex])
        }
    }

    public func clearAll() {
        for(key,_) in self.dictionary() {
            self.removeObjectForKey(key as PreferenceKey)
        }
    }

    public func setObjectToArchive(value: AnyObject?, forKey key: PreferenceKey) {
        Prephirences.archiveObject(value, preferences: self, forKey: key)
    }

    public func setURL(url: NSURL?, forKey key: PreferenceKey){
        self.setObject(url, forKey: key)
    }

}

// MARK: - transformation, archive

// Protocol to modify stored and read values
public protocol PreferenceTransformation {
    // Transform value when reading it
    func reverseTransformedValue<T:Any>(value: PreferenceObject?) -> T?
    // Transform any value before storing it
    func transformedValue<T:Any>(value: T?) -> PreferenceObject?
}

public enum TransformationKey {
    // Default value: do nothing to values
    case None

    // Archive and unarchive for NSCoding objects
    case Archive

    // Use closures to transform
    case ClosureTuple(transform: (Any? -> PreferenceObject?)?, revert: PreferenceObject? -> Any?)
    
    // Use RawValue for raw representable objects
    // case Raw // XXX find a generic way to cast to RawRepresentable

    // Chain multiple transformations
    case Compose(transformations: [PreferenceTransformation])

    #if !os(Linux)
    // Apply an NSValueTransformer
    case ValueTransformer(NSValueTransformer)
    #endif
}
    

extension TransformationKey: Equatable {

    static func compose(transformation: PreferenceTransformation, with transformation2: PreferenceTransformation) -> PreferenceTransformation {
        // if .None return the other
        if let key = transformation as? TransformationKey where key == TransformationKey.None {
            return transformation2
        } else if let key = transformation2 as? TransformationKey where key == TransformationKey.None {
            return transformation
        }
        // first Compose, just append
        if let key = transformation as? TransformationKey {
            switch(key) {
            case .Compose(let transformations):
                var newTransformation: [PreferenceTransformation] = transformations
                newTransformation.append(transformation2)
                return TransformationKey.Compose(transformations: newTransformation)
            default:
                break
            }
        }
        // compose the two transformations
        return TransformationKey.Compose(transformations: [transformation, transformation2])
    }

}

public func ==(lhs: TransformationKey, rhs: TransformationKey) -> Bool {
    switch (lhs, rhs) {

    case (let .Compose(ts1), let .Compose(ts2)):
        if ts1.isEmpty && ts2.isEmpty {
            return true
        }
        return false
    case (let .ValueTransformer(t1), let .ValueTransformer((t2))):
        return t1 == t2
    case (.Archive, .Archive):
        return true
    case (.None, .None):
        return true
    /*case (let .ClosureTuple(t1, r1), let .ClosureTuple(t2, r2)):
        return false*/
    default:
        return false
    }
}

public extension PreferencesType {


    public subscript(key: PreferenceKey, closure: (PreferenceObject?) -> Any?) -> Any? {
        return closure(objectForKey(key))
    }
    
    public subscript(key: PreferenceKey, transformationKey: TransformationKey) -> Any? {
        return transformationKey.get(key, from: self)
    }
    
    public subscript(key: PreferenceKey, transformation: PreferenceTransformation) -> Any? {
        return transformation.get(key, from: self)
    }
    
    #if !os(Linux)
    public subscript(key: PreferenceKey, valueTransformer: NSValueTransformer) -> AnyObject? {
        return  valueTransformer.reverseTransformedValue(objectForKey(key))
    }
    #endif
}

public extension MutablePreferencesType {

    public subscript(key: PreferenceKey, transformationKey: TransformationKey) -> Any? {
        get {
            return transformationKey.get(key, from: self)
        }
        set {
            transformationKey.set(key, value: newValue, to: self)
        }
    }
    
    public subscript(key: PreferenceKey, transformation: PreferenceTransformation) -> Any? {
        get {
            return transformation.get(key, from: self)
        }
        set {
            transformation.set(key, value: newValue, to: self)
        }
    }

    #if !os(Linux)
    public subscript(key: PreferenceKey, valueTransformer: NSValueTransformer) -> AnyObject? {
        get {
            return valueTransformer.reverseTransformedValue(objectForKey(key))
        }
        set {
            assert(valueTransformer.classForCoder.allowsReverseTransformation()) // don't store not decodable value
            let transformedValue = valueTransformer.transformedValue(newValue)
            if transformedValue == nil {
                removeObjectForKey(key)
            }
            else {
                setObject(transformedValue, forKey: key)
            }
        }
    }
    #endif

}

extension PreferenceTransformation {

    public func get<T: Any>(key: PreferenceKey,from preferences: PreferencesType) -> T? {
        let value = preferences.objectForKey(key)
        return reverseTransformedValue(value)
    }

    public func set<T: Any>(key: PreferenceKey, value newValue: T?, to preferences: MutablePreferencesType) {
        if  let transformedValue = self.transformedValue(newValue) {
            preferences.setObject(transformedValue, forKey: key)
        } else {
            preferences.removeObjectForKey(key)
        }
    }

}


extension TransformationKey: PreferenceTransformation {

    public func reverseTransformedValue<T: Any>(value: PreferenceObject?) -> T? {
        switch(self) {
        case .None :
            return value as? T
        case .Archive :
            if let data = value as? NSData {
                return Prephirences.unarchive(data) as? T
            }
            return nil
        case .ValueTransformer(let valueTransformer) :
            return valueTransformer.reverseTransformedValue(value) as? T
        case .ClosureTuple(let (_, revert)) :
            return revert(value) as? T
        case .Compose(transformations: let ts):
            if ts.isEmpty {
                return value as? T
            }
            var currentValue = value
            var slice = ts[ts.indices]
            var tranformation = slice.popFirst()
            while (tranformation != nil)  {
                currentValue = tranformation?.reverseTransformedValue(currentValue)
                tranformation = slice.popFirst()
            }
            return currentValue as? T
        }
    }
    
    public func transformedValue<T:Any>(value: T?) -> PreferenceObject? {
        switch(self) {
        case .None :
            return value as? PreferenceObject
        case .Archive :
            if let archivable = value as? NSCoding {
                return Prephirences.archive(archivable)
            } else {
                return nil
            }
        case .ValueTransformer(let valueTransformer) :
           return valueTransformer.transformedValue(value as? AnyObject)
        case .ClosureTuple(let (transform, _)) :
            return transform == nil ? value as? PreferenceObject : transform?(value)
        case .Compose(transformations: let ts) :
            if ts.isEmpty {
                return value as? PreferenceObject
            }
            var currentValue = value as? PreferenceObject
            var slice = ts[ts.indices]
            var tranformation = slice.popLast()
            while (tranformation != nil)  {
                currentValue = tranformation?.transformedValue(currentValue)
                tranformation = slice.popLast()
            }
            return currentValue
        }
    }
    
}

// MARK: RawRepresentable

extension RawRepresentable where Self.RawValue: Any {
    
    init?(preferenceObject: PreferenceObject?) {
        if let rawValue = preferenceObject as? Self.RawValue {
            self.init(rawValue: rawValue)
        } else {
            return nil
        }
    }
    
    static func rawValueOf(value: Any?) -> PreferenceObject? {
        return (value as? Self)?.rawValue as? PreferenceObject
    }
    
    // Return a transformation object for prephirences
    public static var preferenceTransformation: PreferenceTransformation {
        return TransformationKey.ClosureTuple(transform: Self.rawValueOf, revert: Self.init)
    }
}

public extension PreferencesType {

    // Read a RawRepresentable object
    public func rawRepresentableForKey<T: RawRepresentable>(key: PreferenceKey) -> T? {
        if let rawValue = self.objectForKey(key) as? T.RawValue {
            return T(rawValue: rawValue)
        }
        return nil
    }

}

public extension MutablePreferencesType {

    // Store a RawRepresentable object
    public func setRawValue<T: RawRepresentable where T.RawValue: PreferenceObject>(value: T?, forKey key: PreferenceKey) {
        if let rawValue = value?.rawValue {
            self.setObject(rawValue, forKey: key)
        } else {
            self.removeObjectForKey(key)
        }
    }

}

// MARK: - private
// dictionary append
internal func +=<K, V> (inout left: [K : V], right: [K : V]) { for (k, v) in right { left[k] = v } }


