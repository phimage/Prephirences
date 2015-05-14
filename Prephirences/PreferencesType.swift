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

public protocol PreferencesType {

    subscript(key: String) -> AnyObject? {get}

    func objectForKey(key: String) -> AnyObject?
    func hasObjectForKey(key: String) -> Bool
    
    func stringForKey(key: String) -> String?
    func arrayForKey(key: String) -> [AnyObject]?
    func dictionaryForKey(key: String) -> [NSObject : AnyObject]?
    func dataForKey(key: String) -> NSData?
    func stringArrayForKey(key: String) -> [AnyObject]?
    func integerForKey(key: String) -> Int
    func floatForKey(key: String) -> Float
    func doubleForKey(key: String) -> Double
    func boolForKey(key: String) -> Bool
    func URLForKey(key: String) -> NSURL?
    
    func dictionary() -> [String : AnyObject]
    
    // TODO SequenceType for all Preferences? maybe conflit with CompositePreferences
    //typealias Key = String
    //typealias Value = AnyObject
}

public protocol MutablePreferencesType: PreferencesType {

    subscript(key: String) -> AnyObject? {get set}

    func setObject(value: AnyObject?, forKey key: String)
    func removeObjectForKey(key: String)
    
    func setInteger(value: Int, forKey key: String)
    func setFloat(value: Float, forKey key: String)
    func setDouble(value: Double, forKey key: String)
    func setBool(value: Bool, forKey key: String)
    func setURL(url: NSURL, forKey key: String)
    
    func clearAll()
    func setObjectsForKeysWithDictionary(dictionary: [String : AnyObject])
}

// MARK: usefull functions
// dictionary append
internal func +=<K, V> (inout left: [K : V], right: [K : V]) { for (k, v) in right { left[k] = v } }


// MARK: operators
public func += (inout left: MutablePreferencesType, right: PreferencesType) {
    for (k, v) in right.dictionary() { left[k] = v }
}

public func += (inout left: MutablePreferencesType, right: Dictionary<String,AnyObject>) {
    for (k, v) in right { left[k] = v }
}

public func += (inout left: MutablePreferencesType, right: (String, AnyObject)...) {
    for (k, v) in right { left[k] = v }
}

public func -= (inout left: MutablePreferencesType, right: String) {
    left.removeObjectForKey(right)
}

