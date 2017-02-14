//
//  UserDefaults+Prephirences.swift
//  Prephirences
/*
The MIT License (MIT)

Copyright (c) 2017 Eric Marchand (phimage)

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

/** Prephirences Extends UserDefaults

*/
extension Foundation.UserDefaults: MutablePreferencesType {

    public func dictionary() -> [PreferenceKey : PreferenceObject] {
        return self.dictionaryRepresentation()
    }

    //subscript access
    public subscript(key: PreferenceKey) -> PreferenceObject? {
        get {
            return self.object(forKey: key)
        }
        set {
            if newValue == nil {
                removeObject(forKey: key)
            } else {
                set(newValue, forKey: key)
            }
            switch newValue {
            /*case let v as Int: setInteger(v, forKey: key) // Double 0.9 will be cast to 0, let use NSNumber...
            case let v as Float: setFloat(v, forKey: key)
            case let v as Double: setDouble(v, forKey: key)
            case let v as Bool: setBool(v, forKey: key)
            case let v as NSURL: setURL(v, forKey: key)*/
            case nil: removeObject(forKey: key)
            default: set(newValue, forKey: key)
            }
        }
    }

    #if !USER_DEFAULTS_NO_CLEAR_USING_BUNDLE
    // http://stackoverflow.com/questions/29536336/how-to-clear-all-nsuserdefaults-values-in-objective-c
    public func clearAll() {
        if let bI = Bundle.main.bundleIdentifier {
            self.removePersistentDomain(forName: bI)
        }
    }
    #endif
}

#if os(OSX)
    import AppKit

    extension NSUserDefaultsController: PreferencesType {

        public func object(forKey key: PreferenceKey) -> PreferenceObject? {
            return (self.values as AnyObject).value(forKey: key)
        }

        public func dictionary() -> PreferencesDictionary {
            let keys = Array(self.defaults.dictionary().keys)
            return (self.values as AnyObject).dictionaryWithValues(forKeys: keys)
        }

    }

    extension NSUserDefaultsController: MutablePreferencesType {

        public func set(_ value: PreferenceObject?, forKey key: PreferenceKey) {
            (self.values as AnyObject).setValue(value, forKeyPath: key)
        }

        public func removeObject(forKey key: String) {
            (self.values as AnyObject).setNilValueForKey(key)
        }
    }
#endif
