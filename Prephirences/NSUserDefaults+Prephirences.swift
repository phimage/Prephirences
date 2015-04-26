//
//  NSUserDefaults+Prephirences.swift
//  Prephirences
//
//  Created by phimage on 22/04/15.
//  Copyright (c) 2015 phimage. All rights reserved.
//

import Foundation

/** Prephirences Extends NSUserDefaults

*/
extension NSUserDefaults: MutablePreferencesType {
    // other way is to encapsulate NSUserDefaults in new object NSUserDefaultsPrefs: MutablePreferencesType
    
    public func dictionary() -> [String : AnyObject] {
        return self.dictionaryRepresentation() as! [String:AnyObject]
    }
    public func hasObjectForKey(key: String) -> Bool {
        return objectForKey(key) != nil
    }
    public func clearAll() {
        if let bI = NSBundle.mainBundle().bundleIdentifier {
            self.removePersistentDomainForName(bI)
        }
    }
}

//MARK: subscript access
public var NSUserDefaultsKeySeparator = "."
extension NSUserDefaults {
    
    public subscript(key: String) -> AnyObject? {
        get {
            if let value: AnyObject = self.objectForKey(key) {
                return value
            }
            return MutableProxyPreferences(self, key, NSUserDefaultsKeySeparator)
        }
        set {
            if newValue == nil {
                removeObjectForKey(key)
            } else {
                setObject(newValue, forKey: key)
            }
        }
    }
    
}

// MARK: utility methods
extension NSUserDefaults {
    
    func setObjects(objects: [AnyObject], forKeys keys: [String]) {
        for var keyIndex = 0; keyIndex < keys.count; keyIndex++
        {
            self.setObject(objects[keyIndex], forKey: keys [keyIndex])
        }
    }
    
    func addObjectsAndKeysFromDictionary(keyValuePairs: [String:AnyObject]) {
        for (key, value) in keyValuePairs {
            self.setObject(value, forKey: key)
        }
    }
}

