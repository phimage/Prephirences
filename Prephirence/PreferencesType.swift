//
//  PreferencesType.swift
//  Prephirence
//
//  Created by phimage on 26/03/15.
//  Copyright (c) 2015 phimage. All rights reserved.
//

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
    func dictionaryRepresentation() -> [NSObject : AnyObject]
    
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
    func registerDefaults(registrationDictionary: [NSObject : AnyObject])
}

// MARK: usefull functions
// dictionary append
internal func +=<K, V> (inout left: [K : V], right: [K : V]) { for (k, v) in right { left[k] = v } }
