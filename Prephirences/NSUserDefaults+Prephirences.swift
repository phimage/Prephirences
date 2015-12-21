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

    public func dictionary() -> [String : AnyObject] {
        return self.dictionaryRepresentation()
    }
    
    //subscript access
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
            switch newValue {
            /*case let v as Int: setInteger(v, forKey: key) // Double 0.9 will be cast to 0, let use NSNumber...
            case let v as Float: setFloat(v, forKey: key)
            case let v as Double: setDouble(v, forKey: key)
            case let v as Bool: setBool(v, forKey: key)
            case let v as NSURL: setURL(v, forKey: key)*/
            case nil: removeObjectForKey(key)
            default: setObject(newValue, forKey: key)
            }
        }
    }

    #if !USER_DEFAULTS_NO_CLEAR_USING_BUNDLE
    // http://stackoverflow.com/questions/29536336/how-to-clear-all-nsuserdefaults-values-in-objective-c
    public func clearAll() {
        if let bI = NSBundle.mainBundle().bundleIdentifier {
            self.removePersistentDomainForName(bI)
        }
    }
    #endif
}


#if os(OSX)
    import AppKit

    extension NSUserDefaultsController: PreferencesType {

        public func objectForKey(key: String) -> AnyObject? {
            return self.values.valueForKey(key)
        }

        public func dictionary() -> [String : AnyObject] {
            let keys = Array(self.defaults.dictionary().keys)
            return self.values.dictionaryWithValuesForKeys(keys)
        }

    }

    extension NSUserDefaultsController: MutablePreferencesType {

        public func setObject(value: AnyObject?, forKey key: String) {
            return self.values.setValue(value, forKeyPath: key)
        }

        public func removeObjectForKey(key: String) {
            self.values.setNilValueForKey(key)
        }
    }
#endif


