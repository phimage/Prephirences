//
//  DictionaryPreferences.swift
//  Prephirence
//
//  Created by phimage on 22/04/15.
//  Copyright (c) 2015 phimage. All rights reserved.
//

import Foundation

public class DictionaryPreferences: PreferencesType {
    
    internal var dico : Dictionary<String,AnyObject>
    
    public init(dico: Dictionary<String,AnyObject>) {
        self.dico = dico
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
    
    public func dictionaryRepresentation() -> [NSObject : AnyObject] {
        return self.dico //FIXME return a non mutable representation...
    }
    
    public func writeToFile(path: String, atomically: Bool) {
        (self.dico as NSDictionary).writeToFile(path, atomically: atomically)
    }
}

public class MutableDictionaryPreferences: DictionaryPreferences, MutablePreferencesType {
    
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
    
    public func registerDefaults(registrationDictionary: [NSObject : AnyObject]){
        dico += registrationDictionary as! [String : AnyObject]
    }
    
    public func clearAll() {
        dico.removeAll()
    }
    
}

