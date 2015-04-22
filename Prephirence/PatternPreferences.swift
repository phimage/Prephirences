//
//  PatternPreferences.swift
//  Prephirence
//
//  Created by phimage on 22/04/15.
//  Copyright (c) 2015 phimage. All rights reserved.
//

import Foundation

//MARK: composite pattern
public class CompositePreferences: PreferencesType {
    
    var prefsArray: [PreferencesType] = []
    
    public init(array: [PreferencesType]){
        self.prefsArray = array
    }
    
    public subscript(key: String) -> AnyObject? {
        get {
            for prefs in prefsArray {
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
    public func dictionaryForKey(key: String) -> [NSObject : AnyObject]? {
        return self[key] as? [String: AnyObject]
    }
    public func dataForKey(key: String) -> NSData? {
        return self[key] as? NSData
    }
    public func stringArrayForKey(key: String) -> [AnyObject]? {
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
    
    public func dictionaryRepresentation() -> [NSObject : AnyObject] {
        var dico = [NSObject : AnyObject]()
        for prefs in reverse(prefsArray) {
            dico += prefs.dictionaryRepresentation()
        }
        return dico
    }
}

public class MutableCompositePreferences: CompositePreferences, MutablePreferencesType {
    
    var affectOnlyFirstMutable: Bool

    public override convenience init(array: [PreferencesType]){
        self.init(array: array, affectOnlyFirstMutable: true)
    }
    
    public init(array: [PreferencesType], affectOnlyFirstMutable: Bool){
        self.affectOnlyFirstMutable = affectOnlyFirstMutable
        super.init(array: array)
    }
    
    override public subscript(key: String) -> AnyObject? {
        get {
            for prefs in prefsArray {
                if let value: AnyObject = prefs.objectForKey(key){
                    return value
                }
            }
            return nil
        }
        set {
            for prefs in prefsArray {
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
    public func setURL(url: NSURL, forKey key: String) {
        self[key] = url
    }
    
    public func registerDefaults(registrationDictionary: [NSObject : AnyObject]){
        for prefs in prefsArray {
            if let mutablePrefs = prefs as? MutablePreferencesType {
                mutablePrefs.registerDefaults(registrationDictionary)
                if affectOnlyFirstMutable {
                    break
                }
            }
        }
    }
    public  func clearAll() {
        for prefs in prefsArray {
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
    var separator: String
    
    public init(_ proxiable: PreferencesType, _ parentKey: String, _ separator: String) {
        self.proxiable = proxiable
        self.parentKey = parentKey
        self.separator = separator
    }
    
    public subscript(key: String) -> AnyObject? {
        get {
            let finalKey = self.parentKey + self.separator + key
            if let value: AnyObject = self.proxiable.objectForKey(finalKey) {
                return value
            }
            return ProxyPreferences(self.proxiable, finalKey, self.separator)
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
    public func dictionaryForKey(key: String) -> [NSObject : AnyObject]? {
        return self.proxiable.dictionaryForKey(key)
    }
    public func dataForKey(key: String) -> NSData? {
        return self.proxiable.dataForKey(key)
    }
    public func stringArrayForKey(key: String) -> [AnyObject]? {
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
    public func dictionaryRepresentation() -> [NSObject : AnyObject] {
        return self.dictionaryRepresentation()
    }
}

public class MutableProxyPreferences: ProxyPreferences {
    
    private var mutable: MutablePreferencesType {
        return self.proxiable as! MutablePreferencesType
    }
    
    public init(_ proxiable: MutablePreferencesType, _ parentKey: String, _ separator: String) {
        super.init(proxiable, parentKey, separator)
    }
    
    override public subscript(key: String) -> AnyObject? {
        get {
            let finalKey = self.parentKey + self.separator + key
            if let value: AnyObject = self.proxiable.objectForKey(finalKey) {
                return value
            }
            return ProxyPreferences(self.proxiable, finalKey, self.separator)
        }
        set {
            let finalKey = self.parentKey + self.separator + key
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
    public func setURL(url: NSURL, forKey key: String){
        self.mutable.setURL(url, forKey: key)
    }
    public func clearAll(){
        self.mutable.clearAll()
    }
    public func registerDefaults(registrationDictionary: [NSObject : AnyObject]){
        self.mutable.registerDefaults(registrationDictionary)
    }
}

