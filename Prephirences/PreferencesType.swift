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

// MARK: - Preferences
public protocol PreferencesType {

    func objectForKey(key: String) -> AnyObject?
    func dictionary() -> [String : AnyObject]

    // MARK: Optional methods
    subscript(key: String) -> AnyObject? {get}
    func hasObjectForKey(key: String) -> Bool
    
    
    func stringForKey(key: String) -> String?
    func arrayForKey(key: String) -> [AnyObject]?
    func dictionaryForKey(key: String) -> [String : AnyObject]?
    func stringArrayForKey(key: String) -> [String]?
    func integerForKey(key: String) -> Int
    func floatForKey(key: String) -> Float
    func doubleForKey(key: String) -> Double
    func boolForKey(key: String) -> Bool

    func dataForKey(key: String) -> NSData?
    func URLForKey(key: String) -> NSURL?

    func unarchiveObjectForKey(key: String) -> AnyObject?
    func preferenceForKey<T>(key: String) -> Preference<T>

}

// MARK: - Mutable Preferences
public protocol MutablePreferencesType: PreferencesType {

    func setObject(value: AnyObject?, forKey key: String)
    func removeObjectForKey(key: String)

    // MARK: Optional methods

    subscript(key: String) -> AnyObject? {get set}

    func setInteger(value: Int, forKey key: String)
    func setFloat(value: Float, forKey key: String)
    func setDouble(value: Double, forKey key: String)
    func setBool(value: Bool, forKey key: String)
    func setURL(url: NSURL?, forKey key: String)

    func setObjectToArchive(value: AnyObject?, forKey key: String)
    
    func clearAll()
    func setObjectsForKeysWithDictionary(dictionary: [String : AnyObject])

    func preferenceForKey<T>(key: String) -> MutablePreference<T>
    
    func immutableProxy() -> PreferencesType
}

// MARK: - Default implementations for optional methods
public extension PreferencesType {

    subscript(key: String) -> AnyObject? {
        return objectForKey(key)
    }
    public func hasObjectForKey(key: String) -> Bool {
        return self.objectForKey(key) != nil
    }

    public func stringForKey(key: String) -> String? {
        return self.objectForKey(key) as? String
    }
    public func arrayForKey(key: String) -> [AnyObject]? {
        return self.objectForKey(key) as? [AnyObject]
    }
    public func dictionaryForKey(key: String) -> [String : AnyObject]? {
        return self.objectForKey(key) as? [String : AnyObject]
    }
    public func dataForKey(key: String) -> NSData? {
        return self.objectForKey(key) as? NSData
    }
    public func stringArrayForKey(key: String) -> [String]? {
        return self.objectForKey(key) as? [String]
    }
    public func integerForKey(key: String) -> Int {
        return self.objectForKey(key) as? Int ?? 0
    }
    public func floatForKey(key: String) -> Float {
        return self.objectForKey(key) as? Float ?? 0
    }
    public func doubleForKey(key: String) -> Double {
        return self.objectForKey(key) as? Double ?? 0
    }
    public func boolForKey(key: String) -> Bool {
        return self.objectForKey(key) as? Bool ?? false
    }
    public func URLForKey(key: String) -> NSURL? {
        return self.objectForKey(key) as? NSURL
    }
    

    public func unarchiveObjectForKey(key: String) -> AnyObject? {
        return Prephirences.unarchiveObject(self, forKey: key)
    }
    public func preferenceForKey<T>(key: String) -> Preference<T> {
        return Preference<T>(preferences: self, key: key)
    }

}

public extension MutablePreferencesType {

    public subscript(key: String) -> AnyObject? {
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

    func setInteger(value: Int, forKey key: String) {
        self.setObject(value, forKey: key)
    }
    func setFloat(value: Float, forKey key: String) {
        self.setObject(value, forKey: key)
    }
    func setDouble(value: Double, forKey key: String) {
        self.setObject(value, forKey: key)
    }
    func setBool(value: Bool, forKey key: String) {
        self.setObject(value, forKey: key)
    }

    public func preferenceForKey<T>(key: String) -> MutablePreference<T> {
        return MutablePreference<T>(preferences: self, key: key)
    }
    
    public func immutableProxy() -> PreferencesType {
        return ProxyPreferences(preferences: self)
    }
    
    public func setObjectsForKeysWithDictionary(dictionary: [String : AnyObject]){
        for (key,value) in dictionary {
            self.setObject(value, forKey: key )
        }
    }

    public func setObjects(objects: [AnyObject], forKeys keys: [String]) {
        for keyIndex in 0 ..< keys.count {
            self.setObject(objects[keyIndex], forKey: keys [keyIndex])
        }
    }

    public func clearAll() {
        for(key,_) in self.dictionary() {
            self.removeObjectForKey(key as String)
        }
    }

    public func setObjectToArchive(value: AnyObject?, forKey key: String) {
        Prephirences.archiveObject(value, preferences: self, forKey: key)
    }

    public func setURL(url: NSURL?, forKey key: String){
        self.setObject(url, forKey: key)
    }

}



// MARK: - transformation, archive

public enum TransformationKey {
    case Archive
    case ValueTransformer(NSValueTransformer)
    case ClosureTuple((transform: AnyObject? -> AnyObject?, revert: AnyObject? -> AnyObject?))
    case None
}

public extension PreferencesType {

    public subscript(key: String, valueTransformer: NSValueTransformer) -> AnyObject? {
        return  valueTransformer.reverseTransformedValue(objectForKey(key))
    }

    public subscript(key: String, closure: (AnyObject?) -> AnyObject?) -> AnyObject? {
        return closure(objectForKey(key))
    }
    
    public subscript(key: String, transformation: TransformationKey) -> AnyObject? {
        switch(transformation) {
        case .Archive :
            return unarchiveObjectForKey(key)
        case .ValueTransformer(let valueTransformer) :
            return self["key", valueTransformer]
        case .ClosureTuple(let (_, revert)) :
            return revert(objectForKey(key))
        case .None :
            return objectForKey(key)
        }
    }
}


public extension MutablePreferencesType {

    public subscript(key: String, transformation: TransformationKey) -> AnyObject? {
        get {
            switch(transformation) {
            case .Archive :
                return unarchiveObjectForKey(key)
            case .ValueTransformer(let valueTransformer) :
                return self["key", valueTransformer]
            case .ClosureTuple(let (_, revert)) :
                return revert(objectForKey(key))
            case .None :
                return objectForKey(key)
            }
        }
        set {
            switch(transformation) {
            case .Archive :
                if newValue == nil {
                    removeObjectForKey(key)
                } else {
                    setObjectToArchive(newValue, forKey: key)
                }
                break
            case .ValueTransformer(let valueTransformer) :
                self["key", valueTransformer] = newValue
                break
            case .ClosureTuple(let (transform, _)) :
                let transformedValue = transform(newValue)
                if transformedValue == nil {
                    removeObjectForKey(key)
                } else {
                    setObject(transformedValue, forKey: key)
                }
                break
            case .None :
                if newValue == nil {
                    removeObjectForKey(key)
                } else {
                    setObject(newValue, forKey: key)
                }
                break
            }
        }
    }

    public subscript(key: String, valueTransformer: NSValueTransformer) -> AnyObject? {
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

}



// MARK: - private
// dictionary append
internal func +=<K, V> (inout left: [K : V], right: [K : V]) { for (k, v) in right { left[k] = v } }


