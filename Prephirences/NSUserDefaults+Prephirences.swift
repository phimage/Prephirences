//
//  NSUserDefaults+Prephirences.swift
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
