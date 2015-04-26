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
    
    public func setObjectsForKeysWithDictionary(dictionary: [String:AnyObject]) {
        for (key, value) in dictionary {
            self.setObject(value, forKey: key)
        }
    }
}

//MARK: subscript access
extension NSUserDefaults {
    
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
    
}
